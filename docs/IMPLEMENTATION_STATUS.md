# Vegolo Implementation Status — Phase 1 (MVP)

Scope: Camera + OCR + rule-based engine + history with thumbnails, barcode fallback, app shell/navigation.

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

## Gaps vs. AGENTS.md

- AI Integration (Phase 2): Gemma 3n (TFLite/Core ML) not wired yet.
- Performance: Frame policy present; consider more adaptive FPS and memory telemetry.
- i18n/RTL, Lottie mascot animations, analytics, sync/backup (iCloud/Drive), export/import: not started.
- Minor tech debt: replace `WillPopScope` with `PopScope`; address small analyzer hints; refine async context guards.
  (PopScope done; remaining: analyzer hints, withOpacity deprecation.)

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

- Documentation gathered in `docs/Gemma/` and `docs/Gemma3n/`:
  - Gemma 3/3n model overview, model card, technical report, implementation guide.
  - Tokenizer & prompt format, system instructions, formatter notes.
  - Conversion notebooks and guides (HF safetensors → LiteRT, LiteRT‑LM integration, ONNX path).
  - Android runtime references: Interpreter options, LiteRT‑LM integration guides, tflite_flutter fallback, XNNPACK/NNAPI tuning, Play for On‑device AI.
  - Quantization guidance (post-training INT8) and deployment blogs.
  - Core ML planning references (coremltools + ML Program overview for Gemma-scale models).

- Outstanding artefacts / decisions before implementation:
  - Acquire/verify Gemma 3n SentencePiece tokenizer files (.spm/.model) and confirm redistribution terms.
  - Pin an official LiteRT‑LM sample repo (google-ai-edge / MediaPipe GenAI) with commit/date for reference implementation.
  - Finalise model delivery strategy: Android (Play Asset Delivery vs Play for On-device AI) and iOS (On-Demand Resources/app thinning) with checksum workflow.
  - Confirm Gemma 3/3n licensing/attribution text to surface in-app.

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
