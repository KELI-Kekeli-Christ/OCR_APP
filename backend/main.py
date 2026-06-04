"""
Backend FastAPI OCR — EasyOCR (local GPU/CPU) + DeepSeek Vision API (optionnel).

Usage:
  pip install -r requirements.txt
  uvicorn main:app --host 0.0.0.0 --port 8000

Variables d'environnement :
  DEEPSEEK_API_KEY   → Active DeepSeek Vision en priorité (OCR plus précis)
  USE_GPU            → "true" (défaut) ou "false"
  OCR_LANGS          → langues EasyOCR séparées par virgule, ex: "fr,en" (défaut)
"""

from __future__ import annotations

import base64
import io
import logging
import os
import re
import tempfile
from contextlib import asynccontextmanager
from typing import AsyncGenerator, Optional

import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from PIL import Image
from pydantic import BaseModel, Field

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("ocr-backend")

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
USE_GPU = os.getenv("USE_GPU", "true").lower() == "true"
OCR_LANGS = [l.strip() for l in os.getenv("OCR_LANGS", "fr,en").split(",") if l.strip()]

_easyocr_reader = None
_deepseek_client = None


# ── EasyOCR ──────────────────────────────────────────────────────────────────

def _get_reader():
    global _easyocr_reader
    if _easyocr_reader is not None:
        return _easyocr_reader
    import easyocr  # noqa: PLC0415
    log.info("Chargement EasyOCR langs=%s gpu=%s", OCR_LANGS, USE_GPU)
    _easyocr_reader = easyocr.Reader(OCR_LANGS, gpu=USE_GPU, verbose=False)
    log.info("EasyOCR prêt.")
    return _easyocr_reader


def _easyocr_recognize(pil_image: Image.Image) -> str:
    reader = _get_reader()
    img_arr = np.array(pil_image.convert("RGB"))
    results = reader.readtext(img_arr, detail=1, paragraph=False)
    if not results:
        return ""
    # Trie par position verticale (haut → bas)
    results_sorted = sorted(results, key=lambda r: r[0][0][1])
    lines: list[str] = [text for (_bbox, text, _conf) in results_sorted]
    return "\n".join(lines)


# ── DeepSeek Vision API ───────────────────────────────────────────────────────

def _get_deepseek_client():
    global _deepseek_client
    if _deepseek_client is not None:
        return _deepseek_client
    if not DEEPSEEK_API_KEY:
        return None
    try:
        from openai import OpenAI  # noqa: PLC0415
        _deepseek_client = OpenAI(
            api_key=DEEPSEEK_API_KEY,
            base_url="https://api.deepseek.com/v1",
        )
        log.info("Client DeepSeek Vision initialisé.")
        return _deepseek_client
    except Exception as e:
        log.warning("Impossible d'initialiser DeepSeek: %s", e)
        return None


def _deepseek_recognize(pil_image: Image.Image, prompt: str) -> str:
    client = _get_deepseek_client()
    if client is None:
        raise RuntimeError("DeepSeek API non configuré (DEEPSEEK_API_KEY manquant)")

    buf = io.BytesIO()
    pil_image.convert("RGB").save(buf, "JPEG", quality=95)
    b64 = base64.b64encode(buf.getvalue()).decode()

    user_prompt = prompt.strip() if prompt and prompt.strip() else (
        "Extrais TOUT le texte de cette image exactement tel qu'il apparaît. "
        "Conserve la mise en page : les tableaux en markdown, les formules en LaTeX."
    )

    response = client.chat.completions.create(
        model="deepseek-vl2",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
                    {"type": "text", "text": user_prompt},
                ],
            }
        ],
        max_tokens=4096,
    )
    return response.choices[0].message.content or ""


# ── Lifespan ──────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    if os.getenv("EAGER_LOAD", "false").lower() == "true":
        _get_reader()
    yield


# ── App ───────────────────────────────────────────────────────────────────────

app = FastAPI(
    title="OCR API",
    version="2.0.0",
    description="EasyOCR (local GPU) + DeepSeek Vision API (optionnel si clé fournie)",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class OcrRequest(BaseModel):
    image_base64: str
    prompt: str = ""
    model: str = "easyocr"
    mode: str = "document"


class OcrResponse(BaseModel):
    text: str
    markdown: str
    latex: Optional[str] = None
    tables: list[str] = Field(default_factory=list)
    confidence: float = 0.95
    engine: str = "easyocr"


# ── Utils ─────────────────────────────────────────────────────────────────────

def _decode_image(b64: str) -> Image.Image:
    try:
        data = base64.b64decode(b64)
    except Exception as e:
        raise HTTPException(400, f"image_base64 invalide: {e}") from e
    try:
        img = Image.open(io.BytesIO(data))
        img.load()
        return img.convert("RGB")
    except Exception as e:
        raise HTTPException(400, f"Image illisible: {e}") from e


def _to_markdown(text: str) -> str:
    lines = text.strip().splitlines()
    out: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            out.append("")
            continue
        if stripped.isupper() and len(stripped) < 60:
            out.append(f"## {stripped}")
        else:
            out.append(stripped)
    return "\n".join(out)


def _extract_latex(markdown: str) -> Optional[str]:
    matches = re.findall(r"\$\$?([^$]+)\$\$?", markdown)
    return "\n".join(f"${m}$" for m in matches) if matches else None


def _extract_tables(markdown: str) -> list[str]:
    pattern = r"(\|[^\n]+\|\n\|[-:| ]+\|\n(?:\|[^\n]+\|\n?)+)"
    return re.findall(pattern, markdown, re.MULTILINE)


def _run_ocr(image: Image.Image, prompt: str) -> tuple[str, str]:
    """Retourne (texte_brut, nom_engine)."""
    if DEEPSEEK_API_KEY:
        try:
            text = _deepseek_recognize(image, prompt)
            return text, "deepseek-vl2"
        except Exception as e:
            log.warning("DeepSeek Vision échoué, fallback EasyOCR: %s", e)

    text = _easyocr_recognize(image)
    return text, "easyocr"


# ── Routes ────────────────────────────────────────────────────────────────────

@app.get("/health")
async def health():
    deepseek_ready = bool(DEEPSEEK_API_KEY)
    try:
        import easyocr  # noqa: F401
        easyocr_ready = True
    except ImportError:
        easyocr_ready = False

    import torch
    gpu_available = torch.cuda.is_available()

    return {
        "status": "ok",
        "engines": {
            "deepseek_vision": deepseek_ready,
            "easyocr": easyocr_ready,
        },
        "active_engine": "deepseek-vl2" if deepseek_ready else "easyocr",
        "gpu": gpu_available and USE_GPU,
        "langs": OCR_LANGS,
    }


@app.post("/v1/ocr", response_model=OcrResponse)
async def ocr(req: OcrRequest):
    image = _decode_image(req.image_base64)
    try:
        raw, engine = _run_ocr(image, req.prompt)
    except Exception as e:
        log.exception("OCR échoué")
        raise HTTPException(500, f"OCR échoué: {e}") from e

    markdown = _to_markdown(raw)
    return OcrResponse(
        text=raw.strip(),
        markdown=markdown,
        latex=_extract_latex(markdown),
        tables=_extract_tables(markdown),
        engine=engine,
    )


@app.post("/v1/ocr/stream")
async def ocr_stream(req: OcrRequest):
    image = _decode_image(req.image_base64)

    async def generate() -> AsyncGenerator[bytes, None]:
        raw, _ = _run_ocr(image, req.prompt)
        chunk_size = 32
        for i in range(0, len(raw), chunk_size):
            yield raw[i : i + chunk_size].encode("utf-8")

    return StreamingResponse(generate(), media_type="text/plain")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
