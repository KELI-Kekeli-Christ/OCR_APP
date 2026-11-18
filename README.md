<p align="center">
  <a href="README.md"><b>English</b></a>
  &nbsp;·&nbsp;
  <a href="README.fr.md">Français</a>
  &nbsp;·&nbsp;
  <a href="README.es.md">Español</a>
</p>

# OCR — Scanner de documents IA

Application mobile Flutter de reconnaissance optique de caractères alimentée par **EasyOCR** (local, GPU) et optionnellement **DeepSeek Vision** (API cloud). Backend FastAPI Python.

---

## Fonctionnalités

- **8 modes OCR spécialisés** — Document, Texte libre, Tableaux, Mathématiques, Manuscrit, Carte de visite, Administratif, Mode étudiant
- **Caméra & Galerie** — scan direct ou import depuis la galerie
- **Live Scan** — reconnaissance en temps réel via la caméra
- **Rendu Markdown** — résultats formatés avec titres, listes, tableaux
- **Rendu LaTeX** — équations mathématiques affichées nativement
- **Streaming OCR** — texte affiché au fur et à mesure de la reconnaissance
- **AI Chat** — discussion avec l'IA sur le contenu du document scanné
- **Export** — TXT, Markdown, PDF, DOCX
- **Text-to-Speech** — lecture audio du texte reconnu
- **Historique** — tous les scans sauvegardés localement (Hive)
- **Stockage sécurisé** — clé API et URL backend chiffrées (Keychain / EncryptedSharedPreferences)
- **Mode étudiant** — priorité math et documents académiques

---

## Architecture

```
ocr_scan/
├── lib/                          # Application Flutter
│   ├── core/
│   │   ├── constants/            # AppConstants (URLs, timeouts…)
│   │   ├── network/              # DioClient + RetryInterceptor
│   │   ├── providers/            # Riverpod providers globaux
│   │   ├── security/             # SecureStorageService
│   │   ├── services/             # ExportService, TtsService
│   │   └── theme/                # AppColors, AppTheme
│   ├── domain/
│   │   ├── entities/             # ScanResult, OcrRequest, OcrMode…
│   │   └── repositories/         # Interfaces
│   ├── data/
│   │   ├── datasources/          # ScanLocalDatasource (Hive)
│   │   ├── models/               # ScanResultModel (JSON)
│   │   └── repositories/         # ScanRepositoryImpl
│   ├── ocr/
│   │   ├── providers/            # DeepSeekOcrProvider, MockOcrProvider
│   │   └── services/             # OcrService, OcrFactory
│   └── features/
│       ├── home/                 # Écran d'accueil
│       ├── camera/               # Scanner caméra & galerie
│       ├── live_scan/            # OCR temps réel
│       ├── result/               # Affichage résultat (Markdown / Math / Brut)
│       ├── history/              # Historique des scans
│       ├── ai_chat/              # Chat IA sur document
│       ├── document_viewer/      # Visualiseur de document
│       ├── settings/             # Configuration backend & provider
│       ├── onboarding/           # Introduction
│       └── splash/               # Splash screen
└── backend/                      # Serveur FastAPI Python
    ├── main.py                   # API OCR (EasyOCR + DeepSeek Vision)
    ├── requirements.txt
    └── start.sh
```

---

## Prérequis

### Application Flutter
- Flutter SDK ≥ 3.x / Dart SDK ^3.9.2
- Android SDK (pour Android) ou Xcode (pour iOS)

### Backend Python
- Python ≥ 3.10
- GPU NVIDIA recommandé (CUDA 11.8+) — fonctionne aussi en CPU

---

## Installation

### 1. Backend OCR

```bash
cd backend

# Installer les dépendances
pip install -r requirements.txt

# Démarrer le serveur (OCR local EasyOCR)
bash start.sh

# ou directement :
uvicorn main:app --host 0.0.0.0 --port 8000
```

Le serveur démarre sur `http://localhost:8000`.

**Avec DeepSeek Vision** (meilleure précision, nécessite une clé API) :

```bash
DEEPSEEK_API_KEY=sk-votre-cle bash start.sh
```

**Variables d'environnement :**

| Variable | Défaut | Description |
|---|---|---|
| `DEEPSEEK_API_KEY` | *(vide)* | Clé API DeepSeek — active le moteur cloud en priorité |
| `USE_GPU` | `true` | Mettre `false` pour forcer le CPU |
| `OCR_LANGS` | `fr,en` | Langues EasyOCR (ex: `fr,en,ar,zh`) |
| `EAGER_LOAD` | `false` | `true` pour précharger le modèle au démarrage |

### 2. Application Flutter

```bash
# Installer les dépendances Dart
flutter pub get

# Générer les fichiers de code (Riverpod, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# Lancer sur Android (émulateur ou appareil)
flutter run
```

---

## Configuration dans l'application

Ouvrir **Paramètres** (icône engrenage sur l'écran d'accueil) :

| Champ | Valeur |
|---|---|
| URL Backend | `http://10.0.2.2:8000` — émulateur Android |
| URL Backend | `http://192.168.x.x:8000` — appareil physique (IP locale du PC) |
| Token API | *(optionnel, si le backend est protégé par auth)* |

Appuyer sur **Enregistrer & tester** pour vérifier la connexion.

---

## Moteurs OCR

| Moteur | Type | Qualité | Requis |
|---|---|---|---|
| **EasyOCR** | Local GPU / CPU | Très bon | Aucune clé |
| **DeepSeek Vision** (`deepseek-vl2`) | API cloud | Excellent | `DEEPSEEK_API_KEY` |

Le backend utilise DeepSeek Vision si la clé est fournie, sinon EasyOCR prend le relais. Le nom du moteur actif est affiché dans le titre de l'écran résultat.

---

## API Backend

### `GET /health`

```json
{
  "status": "ok",
  "engines": { "deepseek_vision": false, "easyocr": true },
  "active_engine": "easyocr",
  "gpu": true,
  "langs": ["fr", "en"]
}
```

### `POST /v1/ocr`

**Corps :**
```json
{
  "image_base64": "<base64>",
  "prompt": "",
  "mode": "document"
}
```

**Réponse :**
```json
{
  "text": "Texte brut extrait",
  "markdown": "## Titre\n\nTexte formaté",
  "latex": "$E = mc^2$",
  "tables": ["| Col A | Col B |\n|---|---|\n| ... |"],
  "confidence": 0.95,
  "engine": "easyocr"
}
```

### `POST /v1/ocr/stream`

Même corps que `/v1/ocr` — retourne le texte en streaming (`text/plain`).

---

## Modes OCR

| Mode | Usage |
|---|---|
| Document | PDF, lettres, rapports |
| Texte libre | Capture rapide de n'importe quel texte |
| Tableaux | Préserve la structure en Markdown |
| Mathématiques | Formules et équations → LaTeX |
| Manuscrit | Texte écrit à la main |
| Carte de visite | Extraction des coordonnées structurées |
| Administratif | Formulaires, documents officiels |
| Mode étudiant | Cours, exercices, formules académiques |

---

## Stack technique

### Flutter (client)

| Lib | Rôle |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `dio` | HTTP + retry interceptor |
| `hive_flutter` | Stockage local des scans |
| `flutter_secure_storage` | Chiffrement clés API |
| `flutter_markdown` | Rendu Markdown |
| `flutter_math_fork` | Rendu LaTeX / équations |
| `flutter_animate` | Animations fluides |
| `google_fonts` | Typographie |
| `pdf` + `printing` | Export PDF |
| `share_plus` | Partage natif |
| `flutter_tts` | Lecture vocale |
| `camera` | Capture caméra |
| `image_picker` | Import galerie |

### Python (backend)

| Lib | Rôle |
|---|---|
| `fastapi` + `uvicorn` | Serveur HTTP async |
| `easyocr` | OCR local (PyTorch + CUDA) |
| `openai` | Client DeepSeek Vision API |
| `pillow` + `numpy` | Traitement des images |

---

## Développement

```bash
# Analyser le code Dart
flutter analyze

# Tests
flutter test

# Surveiller les fichiers générés en continu
dart run build_runner watch
```

---

## Plateformes supportées

Android · iOS · Linux · macOS · Windows · Web

---

## Licence

Apache 2.0
