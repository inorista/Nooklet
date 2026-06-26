# Nooklet

Nooklet is a privacy-first, fully offline, on-device AI assistant application for iOS and iPadOS. It features interactive local LLM chat via LiteRT and fast, multi-language Text-to-Speech (TTS) via Supertonic ONNX models. No cloud processing, zero data collection.

> **Note**: We have recently transitioned from Nemotron-3.5 ASR (Speech-to-Text) to Supertonic TTS (Text-to-Speech). The app now reads Assistant responses aloud using high-quality local voices.

## Key Features

- **On-Device LLM Chat (Gemma 2B)**: Interactive, private conversations using Google's Gemma model via the `LiteRTLM` framework.
- **On-Device Text-To-Speech (Supertonic)**: Fast, multi-language voice synthesis using ONNXRuntime. Supports 30+ languages and multiple male/female voice styles.
- **Sliding Context Window Memory**: Auto-resets local LLM context to fit GPU memory limits while injecting recent history into the prompt to preserve short-term memory.
- **Local Persistence (Realm)**: Secure, local storage for all chat history, sessions, messages, and user profile data.
- **Premium UI & iPad Support**: Beautiful, translucent interface featuring native SwiftUI `TabView`, glass effects (`ultraThinMaterial`), custom responsive layouts for iPad, and bouncy card animations.
- **Chat History**: Browse, resume, and manage past AI conversations safely stored on your device.

---

## Tech Stack

- **Platform**: iOS 17.0+ / iPadOS 17.0+
- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Database**: RealmSwift (via SPM)
- **LLM Engine**: LiteRTLM (TensorFlow Lite GenAI)
- **TTS Engine**: Supertonic via ONNXRuntime
- **Project Scaffold**: XcodeGen (1.x)

---

## Prerequisites

- **Xcode 16+** (built and tested with Xcode 16.0+)
- **macOS Sonoma/Sequoia** or newer
- **XcodeGen** (`brew install xcodegen`)
- **On-Device Hardware**: iPhone 15 Pro, iPhone 16 series, or M-series iPads recommended for optimal Neural Engine/GPU performance. (Simulator is supported but falls back to CPU/GPU).

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/inorista/Nooklet.git
cd Nooklet
```

### 2. Setup TTS Models (ONNX)

The Supertonic TTS models are excluded from Git due to their size. You must download them and place them inside the `Nooklet/Helpers/onnx/` directory:
- `duration_predictor.onnx`
- `text_encoder.onnx`
- `vector_estimator.onnx` (~116MB)
- `vocoder.onnx`
- `tts.json`
- `unicode_indexer.json`

*(Ensure your download is complete and the files are not corrupted. A corrupted `vector_estimator.onnx` will result in a `Protobuf parsing failed` error during runtime).*

### 3. Setup LLM Models

Ensure your Gemma 2B model (`gemma-4-E2B-it.litertlm` or compatible format) is placed under the required bundle resources as expected by `LlmInference.swift`.

### 4. Generate the Xcode Project

Nooklet uses XcodeGen to generate its `.xcodeproj` file. Do not commit or modify the `.xcodeproj` directory manually; make changes in `project.yml` and regenerate it:

```bash
xcodegen generate
```

### 5. Open Project & Resolve Dependencies

```bash
open Nooklet.xcodeproj
```

Xcode will automatically fetch the required Swift Package dependencies defined in `project.yml`, including `RealmSwift` and `onnxruntime-swift`.

### 6. Build & Run

```bash
# Build for iOS simulator (ARM64 recommended)
xcodebuild -project Nooklet.xcodeproj -scheme Nooklet -destination 'generic/platform=iOS Simulator' build
```
Or simply press `Cmd + R` in Xcode.

---

## Architecture

### Directory Structure

```text
Nooklet/
├── App/                # App entry point, NookletApp
├── CommonViews/        # Reusable UI controls (BouncyCardStyle, Glass UI)
├── Databases/          # Database Entities (ChatMessageEntity, ChatSessionEntity)
├── Enums/              # Shared enums (AppTab, etc.)
├── Helpers/            # Helper extensions, ONNX model references, Voice Styles
├── Resources/          # Assets.xcassets, AppIcon, Info.plist
├── Screens/            # Feature screens
│   ├── Chat/           # Chat window, bubble rendering, and view models
│   ├── ChatHistory/    # History screen for past sessions (Realm backed)
│   ├── Dashboard/      # Tab bar navigation structure
│   ├── Explore/        # Explore tab
│   ├── Home/           # Greeting screen and recent cards
│   ├── Onboarding/     # Setup screens
│   └── Setting/        # Edit profile and preferences
└── Services/           # Core Services
    ├── Gemma/          # LlmInference for LLM execution
    ├── Supertonic/     # SupertonicService for ONNX TTS
    └── RealmService/   # Local persistence CRUD operations
```

### Request and Data Flow

```text
User Text Input ──▶ ChatViewModel ──▶ LiteRTLM (Gemma 2B)
       │                                         │
       ▼                                         ▼
Realm Database ◀───────────────────────── Assistant Message
                                                 │
                                                 ▼
                                        SupertonicService (TTS)
                                                 │
                                                 ▼
                                          Audio Playback
```

1. **RealmService**: Handles CRUD operations for User profiles, Chat Sessions, and Messages on the `@MainActor` thread.
2. **ChatViewModel**: Manages the conversational state. Ensures LLM context windows stay within device limits (1024 tokens) and injects historical context when needed.
3. **SupertonicService**: Hooks into the assistant's text response, looks up the corresponding `Voice` and `Language` configurations, and runs ONNX inference to generate a `.wav` file for immediate playback.

---

## Troubleshooting

### 1. Protobuf parsing failed (TTS Init Error)
If the app crashes or shows `Failed to init TTS: Protobuf parsing failed`, it means one of your `.onnx` files (usually `vector_estimator.onnx`) is corrupted or empty. 
**Solution**: Delete the file from `Nooklet/Helpers/onnx/` and re-download it completely. Ensure you clean the build folder (`Cmd + Shift + K`) before rebuilding.

### 2. SQLite Database Lock (`disk I/O error`)
If Xcode complains about database locks when building:
```bash
# Clear DerivedData cache
rm -rf ~/Library/Developer/Xcode/DerivedData/Nooklet-*
```

### 3. Missing Xcode Project
If `Nooklet.xcodeproj` is red or missing:
```bash
xcodegen generate
```

---

## License

Source code is released under the [MIT License](LICENSE). Google Gemma and any bundled ONNX models are subject to their own respective licenses.
