# PhotoToPoetry 📸✍️
### *Dissolving Moments into Verses*

PhotoToPoetry is a android app that transforms your photographs into evocative, heartfelt poetry using state-of-the-art AI. By "Reading the light" and "Feeling the colours," the app captures the soul of an image and weaves it into unique verses.

---

## ✨ Features

- **AI-Powered Vision**: Uses Google Gemini with an automatic dual-key rotation system to maximize free-tier rate limits.
- **Interactive Editing**: A beautiful, gesture-driven editor that lets you drag, scale, and style your poetry over your photo.
- **Draft Refinement**: Write a rough draft, and let the AI "weave the soul" of your image into your existing words.
- **Dynamic Aesthetics**: Features a signature "Pixel-Dissolve" animated background where RGB pixels flicker into poetic letters.
- **Privacy-First**: API keys are managed via environment variables and never committed to source.

---

## 🏗️ Project Structure

The repository is organized into a clean split-architecture:

- [**/Photo2PoetryFE**](./Photo2PoetryFE): A modern Flutter application built for high-end mobile experiences.
- [**/Photo2PoetryBE**](./Photo2PoetryBE): A robust Python/FastAPI backend designed for resilient AI communication and rate limiting.

---

## 🚀 Getting Started

### 1. Backend Setup
1. Navigate to `Photo2PoetryBE`.
2. Install dependencies: `pip install -r requirements.txt`.
3. Create a `.env` file with your `GEMINI_API_KEY` and `GEMINI_API_KEY_SECONDARY`.
4. Run the server: `python main.py` or deploy to Hugging Face Spaces.

### 2. Frontend Setup
1. Navigate to `Photo2PoetryFE`.
2. Install Flutter dependencies: `flutter pub get`.
3. Create a `.env` file based on `.env.example` and set your `API_URL`.
4. Run the app: `flutter run`.

---

*Handcrafted for poets and photographers alike.*
