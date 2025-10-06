**Title**: Vegolo – New Session Prompt

**Project Context**
- Vegolo is a Flutter (Material 3) mobile app that determines if products are vegan by scanning ingredient lists with on‑device OCR + rule‑based analysis (AI later). Tone: “Reliably Charming” with a chameleon mascot.
- Offline‑first, trust and transparency focused. iOS + Android.
- Clean Architecture: feature‑based folders, BLoC for state, repository pattern, DI via get_it + injectable, SQLite via drift.
- Tech: camera, google_mlkit_text_recognition (offline), image (thumbnailing), drift/sqlite3, shared_preferences, tflite_flutter (phase 2), permission_handler.

**Current Phase & Status (Phase 1 — MVP)**
- Camera preview + tap‑to‑focus; flash toggle working.
- OCR via ML Kit; basic rule‑based analyzer with E‑number and alias matching.
- History with thumbnails (captured before pause). Thumbnails are default; full images optional via SettingsRepository (UI toggle pending).
- History actions: per‑entry delete, per‑entry “Delete image data”, and “Delete all”.
- OCR normalization added (line‑by‑line and full text) for better tokenization and detectedIngredients capture.
- DI stabilized (scoped generation), SharedPreferences pre‑resolved.
- Tests pass; added coverage for normalization and history behaviors.

**Repository Commands**
- Run: `flutter run -d <deviceId>`
- Tests: `flutter test`
- Analyze/format: `dart analyze`, `dart format .`
- Generate: `dart run build_runner build --delete-conflicting-outputs`

**Suggested Next Steps (Prioritized)**
1) Settings UI (MVP)
   - Add Settings page with a toggle for “Save full image” wired to SettingsRepository.
   - Add “Delete all image data” action (keeps entries but removes all images) if desired.

2) Ingredient Parsing Heuristics
   - Prefer lines following an “ingredients:” header in OCR text; merge multi‑line lists; ignore marketing text.
   - Expand alias/2–3‑gram matching and strengthen E‑number normalization.
   - Surface rationale snippets from the DB when a non‑vegan match triggers.

3) Performance & Robustness
   - Run thumbnail generation in an isolate to avoid UI jank.
   - Debounce analysis when OCR text hasn’t materially changed.
   - Optional: backpressure tuning on frame processing (keep every Nth frame).

4) Barcode Fallback (Optional)
   - Add a quick barcode scan button; show product image/name from Open Food Facts when available; keep offline‑first as primary.

5) Test Coverage
   - Widget test for Settings UI toggle.
   - Unit tests for ingredient section extraction and normalization.

**Acceptance Criteria Ideas**
- Settings toggle persists state and affects history save behavior (full image kept when enabled; otherwise deleted post‑thumbnail).
- DetectedIngredients prefer lines from the “ingredients:” section and show more representative items.
- Thumbnail generation happens off the UI thread; no noticeable jank on stop.

**Request**
- Which next step should I implement first? If Settings UI, I’ll scaffold a page under `lib/features/settings`, wire BLoC/DI if needed, and add a small widget test. If heuristics, I’ll add a lightweight parser to isolate ingredient sections with tests.

