# Vegolo — Phase 2 (AI Integration) Chat Prompt

Use this prompt to start a new agent session focused on integrating on-device AI reasoning (Gemma 3n) into Vegolo.

---

## Project Snapshot
- **App**: Vegolo (Flutter, Material 3) — scans ingredient lists to determine vegan status.
- **Architecture**: Clean Architecture, feature-first folders, BLoC, `get_it` + `injectable`, Drift/SQLite.
- **Phase 1**: Complete. Camera + OCR + rule-based analyzer + barcode/OPEN FOOD FACTS fallback, history with thumbnails, app shell, performance guardrails, accessibility polish.
- **Goal (Phase 2)**: Layer on-device Gemma 3n reasoning (LiteRT‑LM on Android first, Core ML next) to enhance analysis while preserving rule-based guardrails and offline-first guarantees.

## Current Foundations
- Documentation curated under `docs/Gemma/`:
  - Gemma 3/3n model overview, model card, technical report, implementation guide.
  - Tokenizer & prompt format, system instructions, formatter notes.
  - Conversion guides/notebooks (HF safetensors → LiteRT, LiteRT‑LM integration, ONNX path).
  - Android runtime references: Interpreter options, LiteRT‑LM integration guides, tflite_flutter fallback, XNNPACK/NNAPI tuning, Play for On-device AI.
  - Quantization guidance (post-training INT8) and deployment blogs.
  - Core ML planning references (coremltools ML Program guidance, iOS delivery strategies).

## Outstanding Prerequisites
- Obtain/pin Gemma 3n SentencePiece tokenizer artifact(s) (.spm/.model) + redistribution terms.
- Reference LiteRT‑LM sample repo (google-ai-edge / MediaPipe GenAI) with commit/date.
- Finalise model-delivery plan: Android (Play Asset Delivery vs Play for On-device AI) & iOS (On-Demand Resources/app thinning) with checksum workflow.
- Confirm Gemma 3/3n licensing/attribution text for in-app disclosure.

## Phase 2 Objectives (Sprint 1)
1. **Artifacts Manifest** — JSON manifest per variant (Nano/Standard/Full) with SHA-256, quantization, RAM floor, max sequence, storage layout.
2. **ModelManager (Dart)** — Variant selection by RAM, download + checksum, mmap-friendly placement, load/unload/warm state tracking.
3. **Android LiteRT‑LM Bridge (Kotlin)** — Load model with delegates/threads, initialise KV cache, expose generate/analyze with timeouts & telemetry, MethodChannel API (`loadVariant`, `unload`, `isReady`, `generate`).
4. **Tokenizer Pipeline** — SentencePiece integration (Dart or Kotlin) with prompt construction per Gemma spec.
5. **PerformScanAnalysis Integration** — Rules-first; if uncertain → invoke AI → reconcile; strict timeouts and reliable fallbacks.
6. **Dev Telemetry (Android)** — Log model load/inference latency, failures, and fallback reasons (logcat).
7. **Acceptance Fixtures** — Define small deterministic text inputs + expected outputs (rules vs AI) for regression checks.

## Deliverables (initial PR/iteration)
- `lib/core/ai/model_manifest.json` (schema TBD) + utility to parse/validate.
- `lib/core/ai/model_manager.dart` scaffolding with TODOs for download + RAM heuristics.
- Android platform code under `android/app/src/main/kotlin/.../GemmaService.kt` (or similar) with LiteRT‑LM load/generate stubs + MethodChannel wiring.
- Tokenizer hookup (placeholder using SentencePiece; stub fallback if artifact missing).
- Updated `PerformScanAnalysis` showing rule+AI pipeline with feature-flag / config toggle.
- Dev logging demonstrating load/start/stop paths.
- Docs update: add chosen manifest schema + build/run notes (e.g., `docs/Gemma/README.md`).

## Constraints & Principles
- Gemma runs fully on-device; rules remain authoritative fallback.
- Strict timeouts: AI must not block UI > ~250 ms on mid-tier devices.
- Model selection by RAM; provide user-friendly messaging if device cannot host larger variants.
- No network inference; downloads must respect Wi-Fi-only + user consent.

## Quick Commands
- Run app: `flutter run -d <device>`
- Analyze: `dart analyze`
- Tests: `flutter test`
- Build_runner: `dart run build_runner build --delete-conflicting-outputs`
- Wireless debug pattern: `adb connect <ip>:<debug_port>` → `flutter run -d <ip>:<debug_port>`

## Ask the Agent To…
- Draft manifest schema + validation utility.
- Scaffold ModelManager (Dart) with TODOs for download/checksum.
- Author initial Kotlin LiteRT‑LM wrapper + channel interface.
- Design tokenizer abstraction and specify tokenizer artifact placement.
- Outline PerformScanAnalysis changes + fallback logic.
- Plan acceptance fixtures + telemetry metrics.
- Note any assumptions or missing artefacts (tokenizer file, model repo link, license text).

Provide clear work logs, point out open questions, and keep rule-based analyzer fully functional until AI path is verified.
