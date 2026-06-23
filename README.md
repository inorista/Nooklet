# Nooklet

Nooklet is a privacy-first, fully offline, on-device AI assistant application for iOS. It combines streaming automatic speech recognition (ASR) via CoreML and interactive LLM chat via LiteRT, backed by local Realm persistence.

The official app icon and assets are located at `Nooklet/Resources/Assets.xcassets/AppIcon.appiconset`.

---

## Key Features

- **On-Device Streaming ASR**: Real-time, low-latency streaming speech recognition using NVIDIA's **Nemotron-3.5-ASR Streaming 0.6B** model converted to CoreML.
- **Offline File Transcription**: Direct audio file transcription using local hardware acceleration on the Apple Neural Engine (ANE).
- **On-Device LLM Chat (Gemma 2B)**: Interactive, private conversations using Google's Gemma model via the `LiteRTLM` framework.
- **Sliding Context Window Memory**: Auto-resets local LLM context to fit GPU memory limits (max 1024 tokens) while automatically injecting recent history into the prompt to preserve short-term memory.
- **Local Persistence (Realm)**: Secure, local storage for all chat history, sessions, messages, and user profile data.
- **Premium Glassmorphism UI**: Beautiful, translucent interface featuring native SwiftUI `TabView` with system-level glass effects (`ultraThinMaterial`) and custom active/inactive tab bar icons.

---

## Tech Stack

- **Platform**: iOS 17.0+
- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Database**: Realm Swift (10.54.6+)
- **LLM Engine**: LiteRTLM (via local package `/Users/tu/Nooket/LiteRT-LM` / TensorFlow Lite GenAI)
- **ASR Engine**: CoreML (Apple Neural Engine / GPU / CPU fallback)
- **Project Scaffold**: XcodeGen (1.x)

---

## Prerequisites

- **Xcode 16+** (built and tested with Xcode 26.3)
- **macOS Sonoma/Sequoia** or newer
- **XcodeGen** (`brew install xcodegen`)
- **CocoaPods** or standard Swift Package Manager support
- **On-Device Hardware**: iPhone 15 Pro or newer recommended for optimal Neural Engine performance. (Simulator is supported but falls back to CPU/GPU).

---

## Getting Started

### 1. Generate the Xcode Project

Nooklet uses XcodeGen to generate its `.xcodeproj` file. Do not commit or modify the `.xcodeproj` directory manually; make changes in `project.yml` and regenerate it:

```bash
# Generate the Xcode project from project.yml configuration
xcodegen generate
```

### 2. Open Project & Resolve Dependencies

```bash
# Open in Xcode
open Nooklet.xcodeproj
```

Xcode will automatically fetch the required Swift Package dependencies defined in `project.yml`, including `RealmSwift`, `Moya`, `Alamofire`, `SwiftyJSON`, and the local `LiteRTLM` package.

### 3. Build & Test

```bash
# Build for generic iOS simulator
xcodebuild -project Nooklet.xcodeproj -scheme Nooklet -destination 'generic/platform=iOS Simulator' build

# Run unit tests
xcodebuild test -project Nooklet.xcodeproj -scheme Nooklet -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## Model Setup

### ASR Model (NVIDIA Nemotron-3.5-ASR)

The default target is the multilingual RNN-T model @ 2240 ms (~634 MB) supporting English, Chinese, Japanese, and Korean.

```bash
# 1. Download CoreML model files, tokenizer, and metadata
./scripts/download_models.sh multilingual 2240

# 2. Inspect the model signatures to refresh configurations (generates ModelSignatures.json)
python3 scripts/inspect_model.py Models/multilingual/2240ms --out Nooklet/Services/ASR/ModelSignatures.json

# 3. Regenerate project to bundle downloaded models
xcodegen generate
```

### LLM Model (Gemma 2B)

Ensure your Gemma 2B model (`.bin` or compatible `LiteRTLM` format) is placed under the required bundle resources or local cache path as expected by the `LlmInference.swift` service. The default configuration uses:
- **`maxNumTokens`**: 1024 (safe limit for Gemma 2B on iOS GPU).
- **`contextThreshold`**: 800 (triggers local context optimization and history re-injection).

---

## Architecture Overview

### Directory Structure

```
Nooklet/
├── App/                # App entry point, AppCoordinator
├── CommonViews/        # Reusable UI controls and custom views
├── Databases/          # Database Entities (ChatMessageEntity, ChatSessionEntity) and Realm schemas
├── Enums/              # Shared enums (AppTab, etc.)
├── Helpers/            # Helper extensions and formatters
├── Resources/          # Assets.xcassets, AppIcon, Info.plist
├── Screens/            # Feature screens
│   ├── Chat/           # Chat window, bubble rendering, and view models
│   ├── Dashboard/      # Tab bar navigation structure
│   ├── Home/           # Greeting screen and horizontal chat history cards
│   └── Register/       # Local user profile configuration
└── Services/           # Services (RealmService, UserDefaultsService, LlmInference, NemotronASRService)
```

### Request and Data Flow

```
User Voice/Text ──▶ ASR/Input Processing ──▶ ChatViewModel ──▶ LiteRTLM (Gemma 2B)
       │                                         │
       ▼                                         ▼
Realm Database ◀───────────────────────── User & Assistant Messages
```

- **RealmService**: Handles CRUD operations for `User`, `ChatSessionEntity`, and `ChatMessageEntity` on the `@MainActor` thread.
- **ChatViewModel**: Manages the conversational state. When token length approaches the limit, it resets the C++ `Conversation` context and automatically schedules a **Context Injection** of the last 4 messages in the next prompt.
- **AppCoordinator**: Manages screen navigation flow.

---

## Troubleshooting

### 1. SQLite Database Lock (`disk I/O error`)
If Xcode complains about database locks when building:
```bash
# Clear DerivedData cache
rm -rf ~/Library/Developer/Xcode/DerivedData/Nooklet-*
# Resolve package dependencies cleanly
xcodebuild -project Nooklet.xcodeproj -scheme Nooklet -resolvePackageDependencies
```

### 2. Missing CoreML model files
If the app starts but shows a "Models not found" status:
- Ensure the model bundles exist in the `Models/` directory before running `xcodegen generate`. The app degrades gracefully to run benchmarks even when models are absent.

### 3. Simulator Architecture Mismatches (`x86_64`)
The `LiteRTLM` package binary target (`CLiteRTLM`) only supports `arm64` for device and simulator. When building from the command line, compile for Apple Silicon (`arm64`) using:
```bash
xcodebuild -project Nooklet.xcodeproj -scheme Nooklet -destination "generic/platform=iOS" build
```

---

## License

Source code is released under the [MIT License](LICENSE). NVIDIA Nemotron and Google Gemma model weights are subject to their own respective licenses.
