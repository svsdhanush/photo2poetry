# Photo Poem App

The **Photo Poem App** is an AI-powered creative Flutter application. It allows users to import or take a photograph, intelligently generate a poem based on the photo's content, and manipulate the generated text over the image before exporting the final composition to their device's gallery.

---

## 🏗️ Project Architecture & File Structure

The project has a clean, feature-driven architecture divided into screens, components (widgets), and services.

```text
lib/
├── main.dart                          # App Entry Point
├── screens/
│   ├── photo_poem_screen.dart         # Landing screen for image selection (Camera/Gallery)
│   └── poem_editor_screen.dart        # Screen for displaying and staging the image acting as a canvas
├── services/
│   └── poem_api_service.dart          # HTTP logic to communicate with the hugging face model
└── widgets/
    ├── editable_draggable_text.dart   # Interactive canvas component for poem styling
    └── poem_settings_sheet.dart       # Bottom sheet for tweaking AI parameters
```

---

## 🚀 How It Works (The User Flow)

1. **Initialization:** The user opens the app and lands on the `PhotoPoemScreen`.
2. **Image Selection:** Tapping the camera floating action button prompts the user to select an image from their native Gallery or take a fresh photo using the device Camera. Permission requests are handled automatically.
3. **The Editor Canvas:** The user is immediately navigated to the `PoemEditorScreen`, and the original aspect ratio of the image is calculated and maintained.
4. **AI Generation:** As soon as the `PoemEditorScreen` loads, a background request is made to the AI via `poem_api_service.dart`. While generating, an animated "Generating your poem..." text takes the stage.
5. **Editing:** Once the AI responds, the poem text is displayed over the image. The user can interact with the `EditableDraggableText` widget to style, align, and position their poem.
6. **Saving:** Once satisfied, the user presses the Save button. The `Screenshot` package captures purely the image and text overlay, discarding the UI tools, and saves it into the device's native photo gallery.

---

## 🖼️ Screens Details

### 1. Photo Poem Screen (`photo_poem_screen.dart`)
This is the app's home dashboard.
* **Core Job:** Request necessary OS-level permissions (Camera, Photos/Storage) and yield an image file. 
* **Small Features:** Uses native Material `AlertDialog` to let the user pick between the `Camera` and `Gallery`. It also houses a mock 'Settings' app-bar button for configuring poem settings *before* picking an image.

### 2. Poem Editor Screen (`poem_editor_screen.dart`)
This is the core workbench of the application. 
* **Core Job:** Wait for the AI, house the image natively without stretching, host the interactive text widgets, and process the final screen capture for saving.
* **Decoding Mechanism:** Contains `_preloadImageAspect()` which parses the raw `Uint8List` image bytes to determine its native intrinsic size so `AspectRatio` won't distort or crop the user's photo.
* **Bottom Gradient Scrim:** An invisible utility widget (`_BottomGradientScrim`) subtly darkens the bottom of the canvas so text placed downwards can be read easily on very bright photos.

---

## 🧩 Components & Widgets

### 1. Editable Draggable Text (`editable_draggable_text.dart`)
Arguably the most complex piece of the application. It acts as an interactive bounding box wrapping the poem text. 
* **Draggable Positioning:** Utilizes `GestureDetector` `onScaleUpdate` translating the UI element seamlessly around the screen.
* **Pinch-To-Zoom:** Dual-finger scaling scales both the font size and the parent bounding box width & height proportionally.
* **Toolbar:** A floating toolbar inside the bounding box allows for real-time changes securely stored in state:
    * Background Fill toggle (On/Off default black backdrop).
    * Color Picker (to change font color via a modal).
    * Quarter-turn Rotation button.
    * Text Alignment toggle (Left/Center/Right).
    * Restore Default state.
    * Enter Keyboard Edit mode to change the wording.
    * Enter Box Resizing mode to increase the absolute width/height boundaries using a corner grip.

### 2. Poem Settings Sheet (`poem_settings_sheet.dart`)
A robust draggable Bottom Sheet to handle AI prompt generation constraints.
* **Length Constraints:** Allows users to modify how many words the AI should output (Bounded cleanly with min/max clamps via a slider).
* **Preset Chips:** Dynamically suggests adjacent lengths based on the current slider target.
* **Theme Specification:** An interactive text field used to bias the AI's creativity (e.g. "Sad", "Festive", "Nature"). Included are rapid-fire `ActionChip` suggestions that concatenate themes (e.g., "Love, Sadness").

---

## 🛜 Services Layer

### Poem API Service (`poem_api_service.dart`)
Responsible for outer-world communication.
* **Endpoint:** Reaches out to a Hugging Face Space endpoint (`svsdhanush-photo-dec-api.hf.space/generate-poem`).
* **Multipart Payload:** Attaches the `imageFile` natively, as well as sending `poem_length` and the optional `user_theme` field.
* **Robust Parsing:** Strips down raw escape sequences returned from HuggingFace (`\n` to actual physical newline characters) so it renders correctly in Flutter text widgets.

---

## ✨ Features Summary

### Big Features
* **AI Image-To-Text:** Direct integration with an intelligent backend that 'reads' a photo and writes poetry.
* **Advanced Text Canvas Engine:** High-fidelity interactive styling. You can drag, resize, rotate, edit text natively, and change colors in real-time.
* **Aspect Ratio Preservation:** Images are rendered exactly as they were shot without hard bounds causing letter-boxing or cropped edges.
* **Lossless Image Compilation:** Harnesses native byte capturing so the saved `.png` has high graphical fidelity without UI clutter. 

### Small / QoL Features
* **Loading Animations:** Utilizes `animated_text_kit` to provide a typewriter loading effect while the API processes the image securely.
* **Dynamic Settings UI:** Auto-scrolling bottom sheets that dodge the native keyboard automatically using `MediaQuery.viewInsets`.
* **Exif Rotation Awareness:** Checks are present across branches to retain the native `upright` position of raw camera shots avoiding 90-degree sideways saves.
* **Permission Bulletproofing:** Checks for permissions before saving/camera launch, yielding Snackbars or Settings redirection links so the app doesn't crash on restrictive operating systems.

---

## 🛠️ Detailed Implementation Guide

This section dives into the code-level implementation of the app's core mechanics.

### 1. Advanced Draggable and Resizable Text (`EditableDraggableText`)
This widget heavily relies on Flutter's `GestureDetector` to manage continuous state changes and re-builds. 
* **State Variables**: Maintains coordinates (`_position`), dimensional bounds (`_boxWidth`, `_boxHeight`), styling (`_fontSize`, `_textColor`, `_rotationIndex`), and flags (`_editing`, `_resizing`).
* **The Pan / Drag System**: 
  - Tracks `onScaleStart` to capture the `_lastFocalPoint`.
  - Inside `onScaleUpdate`, if `details.pointerCount == 1` it computes the delta (`dx`, `dy`) and mutates `_position`, triggering a `setState` to physically move the `Positioned` widget.
* **The Pinch-to-Zoom System**:
  - Inside `onScaleUpdate`, if `details.pointerCount == 2`, it utilizes `details.scale`. The code multiplies the `_initialBoxWidth` and `_initialFontSize` by the `scaleChange`, clamped to safe bounds (e.g. `clamp(100.0, 1000.0)` for width).
* **Mode Switching**: The `Stack` swaps between displaying an `AutoSizeText` (for view-only auto-wrapping) and a `TextField` (when `_editing` is true).

### 2. Capturing the Image (`Screenshot` Package)
To avoid native Android/iOS view capture complexities, the project employs screen-space capturing:
* The `PoemEditorScreen` creates a `ScreenshotController`.
* Instead of wrapping the entire screen, *only* the `_EditorCanvas` (which has the `Stack` containing the image and the poem) is wrapped in the `Screenshot` widget. This ensures the app bar and control buttons are stripped from the final export.
* When the user presses Save, `_screenshotController.capture()` generates a `Uint8List` of bytes in memory.
* The bytes are temporarily written to a file using `path_provider` (`getTemporaryDirectory`), then permanently passed to `gallery_saver_plus` which signals the native OS media scanner to place it in the gallery.

### 3. Aspect Ratio Preservation
Images pushed into a bounded rectangle (`BoxFit.cover`) often lose their edges if the screen's aspect ratio differs (e.g., 9:16 phone vs 4:3 camera sensor).
* Uses `decodeImageFromList` natively on the image bytes to inspect intrinsic height and width.
* Divides `width / height` to define `_imageAspectRatio`.
* Wraps the rendering `Screenshot` canvas in an `AspectRatio(aspectRatio: _imageAspectRatio)` widget. This forces Flutter's layout engine to mimic the physical photo constraints, bypassing arbitrary UI clipping. 

### 4. Background Form-Data HTTP Requests
Communicating with Hugging Face required bypassing simple `GET`/`POST` JSON due to the image payload.
* Implemented `http.MultipartRequest('POST', uri)`.
* Appends the image physically using `http.MultipartFile.fromPath` and encodes the `poem_length` implicitly as fields.
* Binds everything together calling `request.send()` and awaits the `stream.bytesToString()` to parse the final JSON object.
