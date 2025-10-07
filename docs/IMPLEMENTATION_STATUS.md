# Vegolo Implementation Status — Phase 1 (MVP)

Scope: Camera + OCR + rule-based engine + history with thumbnails, barcode fallback, app shell/navigation.

## What’s Implemented

- Camera + OCR
  - Camera preview with tap‑to‑focus, flash toggle, pause/resume.
  - Frame skipping every Nth frame via `ScannerConfig.processEveryNthFrame`.
  - ML Kit OCR pipeline with normalization and soft error handling.
  - BLoC‑driven scanning lifecycle with lifecycle pause/resume.

- Rule‑Based Analyzer
  - Normalization (tokens, 2–3‑grams), alias/E‑number matching.
  - Deterministic non‑vegan decisions with flagged ingredients and basic confidence.
  - Falls back to “uncertain” when OCR fails.

- Ingredient Database
  - Drift schema for ingredients, aliases, E‑numbers, alternatives, region rules.
  - Seed loader (bundled JSON) and lookup repository.

- History + Thumbnails
  - History entries with compressed thumbnails by default; optional full‑size images via Settings.
  - LRU cache for decoded thumbnails in UI.
  - Detail page shows status, flagged items, and full detected ingredients.

- Barcode Fallback (Open Food Facts)
  - Offline barcode detection (EAN‑8/13, UPC‑A/E).
  - OFF lookup is opt‑in only after explicit barcode scan.
  - When barcode is active, OCR is suspended and OFF ingredients are used for analysis and history.
  - OFF product image preferred for thumbnail when present; product name and “Last updated” displayed with disclaimer.

- App Shell & Navigation
  - Material 3 `NavigationBar` with tabs: Scan, History, Settings.
  - Per‑tab Navigators via `IndexedStack` to preserve state and keep Scan warm.

- Settings
  - “Save full images” toggle (default off).

- DI & Infra
  - `get_it` + `injectable` setup; manual registrations for new services (OFF client, barcode service, HTTP client).

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
  - Implemented with OFF image/name and ingredients; OFF‑only in barcode mode for clarity/trust (no OCR in barcode flow).
  - OFF call is opt‑in; “Last updated” displayed.

## Gaps vs. AGENTS.md

- AI Integration (Phase 2): Gemma 3n (TFLite/Core ML) not wired yet.
- Performance: Thumbnail isolate + OCR debounce not implemented; frame policy present.
- Ingredient heuristics: Prefer lines after “ingredients:” and merge multi‑line lists not yet added.
- i18n/RTL, Lottie mascot animations, analytics, sync/backup (iCloud/Drive), export/import: not started.
- Minor tech debt: replace `WillPopScope` with `PopScope`; address small analyzer hints; refine async context guards.

## Acceptance Criteria (Phase 1) — Current Status

- Barcode button flows to product info + image from OFF with “Last updated”: achieved.
- History shows OFF image/name and populates with OFF ingredients when barcode used: achieved.
- Bottom navigation preserves Scan state; camera stays warm: achieved.
- Thumbnails default; full images optional; pipeline stable without UI jank: achieved (thumbnail generation currently on main isolate; plan to move to isolate).

## Next Steps (Shortlist)

- Ingredient Heuristics: prefer “ingredients:” header; merge multi‑line entries; ignore marketing text.
- Performance: thumbnail generation in isolate; debounce OCR when text is stable.
- Tests: widget test for nav state preservation; barcode end‑to‑end widget test with mocks.
- Polish: adopt `PopScope`; minor analyzer fixes; add OFF “no ingredients available” note when data missing.

