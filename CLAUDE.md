# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

On-device, offline, streaming ASR PoC for iPhone/iPad using NVIDIA **Nemotron-3.5-ASR
Streaming 0.6B** (multilingual) via CoreML. The app is intentionally built to **run
without the model weights present** — it captures mic audio, resamples to 16 kHz,
chunks to the streaming tier, and reports benchmark metrics, showing a "models missing"
status until the ~634 MB CoreML bundle is downloaded. Real inference (Phases 5–7) is
not yet wired in; see the phase table in `README.md` for current state.

## Project generation & build

The Xcode project is **generated from `project.yml` via XcodeGen** — `*.xcodeproj` is
gitignored. Always run `xcodegen generate` after editing `project.yml`, after adding/
removing source files, or after downloading models (so `Models/` is re-bundled).

```bash
xcodegen generate                                    # regenerate the project
xcodebuild -scheme Nooklet \
  -destination 'generic/platform=iOS Simulator' build
xcodebuild test -scheme Nooklet \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# single test:
xcodebuild test -scheme Nooklet \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:NookletTests/AudioPipelineTests/testResamplerDownsamplesTo16k
```

The simulator builds/runs the full shell (audio + benchmark) but **cannot run real
inference** — a physical device (iPhone 15 Pro+ for ANE) is required for that.

## Model setup (separate from build)

```bash
./scripts/download_models.sh multilingual 2240       # → Models/multilingual/2240ms/
python3 scripts/inspect_model.py Models/multilingual/2240ms \
  --out Nooklet/Services/ASR/ModelSignatures.json      # regenerate signatures if tier changes
xcodegen generate                                    # re-bundle Models/ into the app
```

`Models/**` is gitignored (license-bound weights). `Models/` is referenced in
`project.yml` as an **optional folder** (`type: folder`), so `.mlmodelc` bundles are
copied as resources when present and the app still builds when absent.

## Architecture (MVVM + Per-Screen Folders)

The project follows the **MVVM** (Model-View-ViewModel) pattern with **per-screen folders**
under `Screens/` and a centralised `AppRouter` for SwiftUI navigation:

```
┌─── App/ ──────────────────────────────────────────────────┐
│  NookletApp (@main)                                │
│  AppRouter (@Observable — Route enum + NavigationPath)     │
│  RootView (NavigationStack host)                          │
└───────────────────────────────────────────────────────────┘
                          │
┌─── Models/ (shared) ────┼─────────────────────────────────┐
│  ASRSessionStatus, ASRLanguage, StreamingTier,            │
│  BenchmarkSnapshot, LanguagePromptMap                     │
└─────────────────────────┼─────────────────────────────────┘
                          ▲
┌─── Screens/Recording/ ──┼─────────────────────────────────┐
│  ViewModels/                                              │
│    RecordingViewModel (@Observable @MainActor)            │
│  Views/                                                   │
│    RecordingScreen, TranscriptView, BenchmarkPanelView    │
│  Models/ (screen-specific, currently empty)               │
└────────────┬────────────┼─────────────────────────────────┘
             │            │
             │            └─── Services/ ───────────────────┐
             │            RecordingService (@MainActor)      │
             │              drives ASRState + pipeline       │
             │            Services/ASR/ (CoreML pipeline)    │
             │            Services/Audio/ (mic + resample)   │
             │            Services/Benchmark/ (metrics)      │
             └────────────────────────────────────────────────┘
```

Navigation flow:

```
NookletApp → AppRouter (environment) → RootView
  └── NavigationStack(path: $router.path)
        └── RecordingScreen (home)
              └── .navigationDestination(for: Route.self) { ... }
```

Audio pipeline (Phases 1–3, working today):

```
AVAudioEngine → AudioResampler (16 kHz mono) → AudioChunkBuffer (tier-aligned chunks)
                                                      │
                          RecordingService ←──────────┘  (@MainActor)
                              drives BenchmarkLogger + ASRState (@Observable)
                              ↓
                   RecordingViewModel → RecordingScreen / TranscriptView / BenchmarkPanelView
```

- **`App/AppRouter.swift`** — `Route` enum (`.recording`, `.settings`) + `AppRouter`
  (`@Observable`) wrapping `NavigationPath`. Push/pop/popToRoot helpers.
- **`App/RootView.swift`** — hosts `NavigationStack(path:)` and dispatches
  `.navigationDestination(for: Route.self)` to the correct screen.
- **`Models/`** — Shared data types (`ASRSessionStatus`, `ASRLanguage`, `StreamingTier`,
  `BenchmarkSnapshot`) used across all layers.
- **`Screens/Recording/ViewModels/RecordingViewModel.swift`** — the MVVM ViewModel.
  Wraps `ASRState` + `RecordingService`, exposes observable state and actions. All
  UI-related computed properties (`canStart`, `statusColor`, `isSessionActive`) live here.
- **`Screens/Recording/Views/`** — SwiftUI views that bind exclusively to the ViewModel.
- **`Services/RecordingService.swift`** — the orchestrator (formerly RecordingController).
  `consume(chunk:)` is the single seam where Phases 5–7 plug in real inference
  (preprocessor → encoder(cache) → RNN-T decode → tokenizer).
- **`Services/ASR/ASRState.swift`** — `@Observable` `@MainActor` state bridging pipeline
  and UI (status, selected language, partial/final transcript, benchmark snapshot).
- **`Services/Audio/`** — `AudioRecorder` (AVAudioEngine), `AudioResampler` (→16 kHz mono),
  `AudioChunkBuffer` (emits fixed-size chunks per `StreamingTier`: 560/1120/**2240**/4480 ms).
- **`Services/Benchmark/`** — `LatencyTracker` (p50/p90/p99, RTF), `MemoryMonitor`, `BenchmarkLogger`.
- **`Support/ModelLocator.swift`** — locates/validates the bundle; reports a clear
  missing-reason for graceful degradation. Required modules: `preprocessor`, `encoder`,
  `decoder_joint` (fused default); `decoder`/`joint` are optional fallbacks.


### Signature-driven, never hardcoded

`scripts/inspect_model.py` reads the real CoreML model and emits
`Nooklet/Services/ASR/ModelSignatures.json`. At runtime `ModelSignatures.swift` loads it
so **tensor names, shapes, the vocab/blank index, and the language→`prompt_id` map are
all data, never hardcoded** in Swift. When changing models/tiers, regenerate this JSON
rather than editing constants. Key facts it carries: 16 kHz mono, 128 mel features,
vocab 13,087 (blank_idx 13087), encoder caches are **explicit input/output tensors**
(`cache_channel`/`cache_time`/`cache_len`, not `MLState`) and must be threaded across
chunks. Languages without a dedicated prompt (e.g. Cantonese) fall back to `auto`.

## Reference docs

`IMPLEMENTATION-PLAN.md` (engineering plan + phase breakdown) and `proposed-plan.md`
(original product intent) are the source of truth for what each phase should deliver.
