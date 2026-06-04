#!/usr/bin/env bash
# Démarrer le backend OCR
# Variables optionnelles :
#   DEEPSEEK_API_KEY=sk-xxx  → active DeepSeek Vision (meilleure qualité)
#   USE_GPU=false            → forcer CPU
#   OCR_LANGS=fr,en,ar       → langues supplémentaires
#   EAGER_LOAD=true          → charger le modèle au démarrage

cd "$(dirname "$0")"
pip install -r requirements.txt -q

exec uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
