# Vegolo Implementation Status — Phase 1 (MVP) & Phase 2 (AI Integration)

Scope to date:
- **Phase 1 (MVP)**: Camera + OCR + rule-based engine + history with thumbnails, barcode fallback, app shell/navigation.
- **Phase 2 (in-progress)**: Gemma 3n manifest + runtime integration, streaming bridge, configurable decode settings, legal notices.

## What’s Implemented

- Camera + OCR
  - Camera preview with tap‑to‑focus, flash toggle, pause/resume.
  - Frame skipping every Nth frame via `ScannerConfig.processEveryNthFrame`.
  - ML Kit OCR pipeline with normalization and soft error handling.
  - OCR debounce (time + text‑based) to avoid redundant analysis.
  - BLoC‑driven scanning lifecycle with lifecycle pause/resume.

- Rule‑Based Analyzer
  - Normalization (tokens, 2–3‑grams), alias/E‑number matching.
  - Ingredients heuristics: extract ingredients section by headers (multi‑language), merge wrapped lines, drop obvious marketing noise.
  - Deterministic non‑vegan decisions with flagged ingredients and basic confidence.
  - Falls back to “uncertain” when OCR fails.

- Ingredient Database
  - Drift schema for ingredients, aliases, E‑numbers, alternatives, region rules.
  - Seed loader (bundled JSON) and lookup repository.

- History + Thumbnails
  - History entries with compressed thumbnails by default; optional full‑size images via Settings.
  - LRU cache for decoded thumbnails in UI.
  - Thumbnails generated in an isolate to avoid UI jank.
  - Detail page shows status, flagged items, and full detected ingredients.
  - Auto‑navigate to detail after saving a scan (Text mode via Stop; Barcode mode auto‑stops on decode).

- Barcode Fallback (Open Food Facts)
  - Offline barcode detection (EAN‑8/13, UPC‑A/E).
  - Two first‑class scan modes: Text (OCR) and Barcode (OFF). Mode toggle via segmented control.
  - In Barcode mode, OCR is suspended and OFF ingredients are used for analysis/history.
  - Auto‑stop once a barcode is decoded; detail opens automatically (no extra Stop action needed).
  - Single‑shot fallback: capture still and decode once for devices with stream quirks.
  - OFF product image preferred for thumbnail; product name and “Last updated” displayed with disclaimer.
  - OFF cache: in‑memory LRU + on‑disk cache (TTL) for offline reuse and fewer network calls.

- App Shell & Navigation
  - Material 3 `NavigationBar` with tabs: Scan, History, Settings.
  - Per‑tab Navigators via `IndexedStack` to preserve state and keep Scan warm.
  - Updated to use `PopScope.onPopInvokedWithResult` for modern back behavior.

- Settings
  - “Save full images” toggle (default off).
  - OFF cache section: shows item count and size; supports clearing cache.

- DI & Infra
  - `get_it` + `injectable` setup; manual registrations for new services (OFF client, barcode service, HTTP client).
  - OFF cache wired into BarcodeRepository; SharedPreferences pre‑resolved.

- Tests
  - Unit coverage for normalization, rule‑based analyzer, scanning BLoC basics.
  - OFF product JSON mapper test.

## Alignment With AGENTS.md

- Phase 1 — MVP
  - Flutter skeleton (Material 3): done.
  - Camera + realtime preview: done.
  - ML Kit OCR: done.
  - Rule‑based detection + small DB: done (seed + lookups).
  - Explanations + uncertainty: basic (flagged ingredients + uncertain copy).
  - History with compressed thumbnails: done (plus full image toggle).
  - Basic UI with instant feedback: done (scan status + mascot component).

- Barcode Fallback
  - Implemented with OFF image/name and ingredients; Barcode mode uses OFF only (no OCR).
  - Auto‑stop on decode with automatic detail navigation; “Last updated” displayed.

## Phase 2 Progress (Gemma 3n Integration — Android)

- **Model manifest & delivery**
  - `lib/core/ai/model_manifest.json` now targets Vegolo’s CDN mirrors for the LiteRT-LM bundles (E2B/E4B int4) with pinned per-file SHA-256 values.
  - Unit-test fixture (`build/unit_test_assets/.../model_manifest.json`) kept in sync.
  - Remaining TODO: once zipped CDN artefacts are finalised, run `dart tool/update_gemma_manifest.dart --nano <path> --standard <path> --full <path>` to backfill `archive_sha256` / `archive_size_bytes` in both manifest and docs.

- **ModelManager runtime**
  - Warm-load path now logs variant, quantisation, and load latency.
  - Added streaming warm-up ping (TTFT telemetry) via `GemmaRuntimeChannel.streamGenerate`.

- **Platform channel & runtime**
  - `GemmaService.kt` upgraded to use `generateResponseAsync`, exposing partial-token streaming over `EventChannel` with cancellation, TTFT, and latency telemetry.
  - Synchronous `generate` still available (wraps async call).

- **Flutter bridge**
  - `GemmaRuntimeChannel` now provides `streamGenerate` with cancellation + chunk metadata.
  - `GemmaService.analyze` consumes streaming output, parses Gemma JSON into `VeganAnalysis`, logs TTFT/latency, and exposes progress callbacks.
- **Telemetry**
  - Added `TelemetryService` (default `DebugTelemetryService`) that logs structured Gemma inference metrics (status, TTFT, latency, finish reason).
  - `GemmaService` records success, parse failure, timeout, and cancellation events so we can later swap in a production sink without touching call sites.

- **User configuration & legal**
  - Added `GemmaGenerationOptions` model, persisted via `SharedPrefsSettingsRepository`.
  - Settings page now includes a “Gemma generation settings” sheet (max tokens, temp, top‑p, top‑k, deterministic seed) and a modal viewer for `GEMMA_LEGAL_NOTICES.txt`.
  - `pubspec.yaml` updated to bundle the legal notice asset.

- **Tests**
  - Updated mocks/fakes for `SettingsRepository`.
  - `PerformScanAnalysis` test suite now asserts generation options are passed through.
  - `flutter test`, `dart analyze`, and `./gradlew app:assembleDebug` run clean (warnings only).

## Gaps vs. AGENTS.md (current delta)

- **AI response parsing**: ✅ Structured parser + unit tests added; follow up with on-device validation once Gemma responses are available.
- **Archive metadata**: scripted (`tool/update_gemma_manifest.dart`) but still needs final checksum/size values once CDN uploads are available; add smoke test for `ModelManager` download/extract path.
- **Telemetry sink**: ✅ Gemma stream data now flows through `TelemetryService`; next step is swapping the debug logger for the production analytics target and defining retention/PII guidance.
- **Cross-platform**: Core ML integration, iOS delivery strategy, sync/backups, analytics, i18n/RTL, mascot animations remain outstanding (unchanged from prior plan).
- **Tech debt**: analyzer hints (`withOpacity` deprecation, async context guards) still pending; consider addressing alongside UI work.

## Acceptance Criteria (Phase 1) — Current Status

- Barcode button flows to product info + image from OFF with “Last updated”: achieved.
- History shows OFF image/name and populates with OFF ingredients when barcode used: achieved.
- Bottom navigation preserves Scan state; camera stays warm: achieved.
- Thumbnails default; full images optional; pipeline stable without UI jank: achieved (thumbnail generation currently on main isolate; plan to move to isolate).
  (Now running thumbnail generation in an isolate.)

## Remaining Phase 1 Polish (Optional)

- Stability & performance
  - Add device‑specific camera quirk handling if needed; optional “conservative” single‑shot default on problematic devices.
  - Add lightweight telemetry hooks (dev builds) to log frame rate, analysis latency, and ImageReader warnings.
  - Clean analyzer infos (async context guards) and replace `withOpacity` usages.

- Testing
  - Widget/integration tests for: mode toggle, auto‑stop barcode, auto‑navigate to detail, single‑shot fallback, OFF cache clear.
  - Golden tests for barcode overlay.

- Documentation
  - Wireless Debugging quick guide (template prepared in conversation).

## Phase 2 Preparation Summary

- Documentation gathered in `docs/Gemma/`:
  - Gemma 3/3n model overview, model card, technical report, implementation guide.
  - Tokenizer & prompt format, system instructions, formatter notes.
  - Conversion notebooks and guides (HF safetensors → LiteRT, LiteRT‑LM integration, ONNX path).
  - Android runtime references: Interpreter options, LiteRT‑LM integration guides, tflite_flutter fallback, XNNPACK/NNAPI tuning, Play for On‑device AI.
  - Quantization guidance (post-training INT8) and deployment blogs.
  - Core ML planning references (coremltools + ML Program overview for Gemma-scale models).

- Outstanding artefacts / decisions before implementation:
  - ✅ Acquire/verify Gemma 3n SentencePiece tokenizer (hash pinned; legal notice bundled).
  - ✅ Document licensing/attribution copy (Settings modal wired to `GEMMA_LEGAL_NOTICES.txt`).
  - ⏳ CDN release checklist: archive-level checksum/size publication (automation available via `tool/update_gemma_manifest.dart`).
  - ⏳ Reference LiteRT-LM sample commit & delivery strategy for iOS/Core ML parity.

- With the above addressed, the team is ready to start **Phase 2 — AI Integration** (Android LiteRT‑LM text-only first, Core ML to follow).

## Phase 2 — AI Integration (Outline)

- Model manager
  - Lazy‑load Gemma 3n variants via TFLite/Core ML; RAM‑based selection (Nano/Standard/Full).
  - Quantized builds; delegates (NNAPI/Core ML); warm model after first load.

- Multimodal reasoning
  - Fuse OCR text + image crops (or full frame) for confidence scoring and alternatives.
  - Cache results and invalidate on model/DB version changes.

- Robust fallbacks
  - If model load/inference fails, clean switch to rules and surface guidance.

- Acceptance
  - Offline inference works; latency within budget on mid‑tier devices; confidence/alternatives populate.
