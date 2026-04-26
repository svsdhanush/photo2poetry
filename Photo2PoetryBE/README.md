---
title: PhotoToPoetry Backend
emoji: ✍️
colorFrom: indigo
colorTo: blue
sdk: fastapi
app_file: app.py
pinned: false
---

# PhotoToPoetry Backend

This is the FastAPI backend for the PhotoToPoetry application. It generates evocative poems based on uploaded images and user-provided themes or rough drafts.

## Setup for Hugging Face Spaces

1. **SDK:** This Space uses the `fastapi` SDK.
2. **Secrets:** You must add the following secrets in the **Settings > Variables and Secrets** tab:
    - `GEMINI_API_KEY`: Your primary Google AI Studio API key.
    - `GEMINI_API_KEY_SECONDARY`: A secondary key from a different account (to bypass rate limits).

## API Endpoints

### `POST /generate-poem`
- **image**: (File) Upload an image.
- **poem_length**: (Form field, int) Target word count.
- **user_theme**: (Form field, string, optional) Desired theme.
- **rough_draft**: (Form field, string, optional) User's original draft for polishing.
