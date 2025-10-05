# Vegolo — AI Agent Instructions (AGENTS.md)

## Project Overview
Vegolo is a global mobile app that helps users identify whether products are vegan by scanning ingredient lists with the camera and **on-device AI** in real time. The product aims to be **"Reliably Charming"**—balancing professionalism with a playful, trustworthy feel (Duolingo-inspired).

- **Mascot**: A chameleon (with glasses) that changes color based on analysis results (green = vegan, red = non‑vegan, yellow = uncertain).
- **Target**: Global audience.
- **Approach**: Offline‑first with optional cloud sync.
- **Trust & transparency**: Clear reasons, confidence scores, and a "double‑check" option.

## Vision & Principles
- **Global accessibility**: Works offline (OCR + AI on device).
- **Speed & simplicity**: Instant feedback during scanning; minimal taps to result.
- **Trust**: Explanations, rationale, and clear uncertainty handling.
- **Reliability**: Rule‑based guardrails + AI reasoning for robustness.
- **Clean Architecture**: Modular, testable, and maintainable.

## Tech Stack
- **Framework**: Flutter (iOS & Android) using Material 3
- **AI/ML**: Google **Gemma 3n** via TensorFlow Lite (Android) / Core ML (iOS)
- **OCR**: Google ML Kit (offline, 50+ languages)
- **State Management**: BLoC (`flutter_bloc`)
- **Database**: SQLite with `drift` (bundled seed DB + migrations)
- **Dependency Injection**: `get_it` + `injectable`
- **Architecture**: Clean Architecture with feature-based structure
- **Sync (optional)**: iCloud / Google Drive for history backups

## Architecture Principles
- Repository pattern with clear domain/data separation.
- Dependency injection for testability.
- BLoC for predictable state and testable UI.
- **Multimodal analysis**: both image and extracted text go to AI when needed.
- Progressive enhancement: start with deterministic rules, then layer AI.

## Project Structure
```
lib/
├── core/
│   ├── ai/
│   │   ├── gemma_service.dart          # TFLite/Core ML integration
│   │   └── model_manager.dart          # Model loading & caching
│   ├── camera/
│   │   ├── scanner_service.dart        # Camera stream management
│   │   └── ocr_processor.dart          # ML Kit text recognition
│   ├── database/
│   │   ├── ingredient_repository.dart  # Ingredient CRUD
│   │   └── scan_history_repository.dart
│   └── di/
│       └── injection.dart              # Dependency injection setup
├── features/
│   ├── scanning/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   └── pages/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── data/
│   │       ├── models/
│   │       └── repositories/
│   ├── history/
│   ├── ingredients/
│   └── settings/
├── shared/
│   ├── widgets/
│   │   ├── chameleon_mascot.dart
│   │   └── scan_result_card.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── constants.dart
└── main.dart
```

## Key Data Models
### `VeganAnalysis`
```dart
class VeganAnalysis {
  final bool isVegan;
  final double confidence;
  final List<String> flaggedIngredients;
  final List<String> alternatives;

  VeganAnalysis({
    required this.isVegan,
    required this.confidence,
    required this.flaggedIngredients,
    required this.alternatives,
  });
}
```
### `Ingredient`
```dart
enum VeganStatus { vegan, nonVegan, maybe }

class Ingredient {
  final String id;
  final String name;
  final VeganStatus status; // vegan, nonVegan, maybe
  final String? category;
  final List<String> alternatives;

  // Suggested metadata for quality & provenance:
  final List<String> aliases;     // synonyms, languages
  final List<String> enumbers;    // e.g., E120
  final Map<String, String> regionRules; // "EU", "US" etc.
  final String? rationale;        // explanation
  final String? sourceUrl;
  final DateTime? lastVerifiedAt;
  final double? uncertainty;      // 0..1
  final bool? processingAid;      // true if only aid

  Ingredient({
    required this.id,
    required this.name,
    required this.status,
    this.category,
    this.alternatives = const [],
    this.aliases = const [],
    this.enumbers = const [],
    this.regionRules = const {},
    this.rationale,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.uncertainty,
    this.processingAid,
  });
}
```

### `ScanHistoryEntry`
```dart
class ScanHistoryEntry {
  final String id;
  final DateTime scannedAt;
  final VeganAnalysis analysis;
  final String? productName;
  final String? barcode;
  final String? thumbnailPath;     // Path to compressed thumbnail
  final String? fullImagePath;     // Optional: path to full-size image
  final bool hasFullImage;         // Flag for UI purposes
  final List<String> detectedIngredients;
  
  ScanHistoryEntry({
    required this.id,
    required this.scannedAt,
    required this.analysis,
    this.productName,
    this.barcode,
    this.thumbnailPath,
    this.fullImagePath,
    this.hasFullImage = false,
    this.detectedIngredients = const [],
  });
}
```

## OCR & AI Pipeline
### Challenges
- Tiny fonts, curved packaging, glare, mixed languages, E‑numbers, special characters.
- OCR misreads: dropped letters, split lines, garbled sequences.

### Strategy
- **Hybrid OCR/AI**: ML Kit for text → normalization → AI correction/reasoning.
- **Pre-/post‑processing**:
  - Unicode normalization, lowercasing.
  - Merge across line breaks; remove bullets/punctuation noise.
  - Spell similarity (e.g., Levenshtein) to fix near‑misses.
  - E‑number normalization and mapping to aliases.
- **AI as fuzzy interpreter**: Feed OCR output + image crop(s) to resolve errors.
- **Frame policy**: Process every Nth frame (e.g., 3rd) with latest‑wins backpressure.
- **Still image fallback** if FPS drops.
- **Camera UX**: Flash/exposure toggle, haptic "hold still".

## Ingredient Database
- **Role**: Small, sharp, high‑certainty set (≈200–500+) for immediate decisions.
- **Seed**: Bundled SQLite via `drift` (preload ≈10 MB; scalable to 5 000+ entries).
- **Sync**: Optional delta updates (Wi‑Fi only, ~weekly). Track provenance and last verification.
- **Flow**:
  1. If ingredient in DB → deterministic decision (green/red) with rationale.
  2. Else AI interprets (synonyms, context, composition).
  3. If AI uncertain → return *Uncertain* with double‑check guidance.

## History Feature

### Purpose
Including a product image in history greatly improves user experience by making it easier to recognize past scans. Without a visual cue, the history list can feel abstract and harder to navigate.

### Strategy
- **Default (MVP)**: Save a **compressed thumbnail** (around 200px wide JPEG, ~20–50 KB) locally with each history entry.
- **Optional setting**: Users can enable *"Save full image"* in app settings for more detail.
- **Sync/Backup**: Only thumbnails are synced (E2EE if Vegolo sync is enabled). Full-size images remain on the device only.
- **Fallback**: If a barcode is scanned, prefer using the **Open Food Facts product image** if available; otherwise, fallback to the locally captured thumbnail.

### UI Usage
- **History list**: Display thumbnail + product name (if identified) + decision icon (green/red/yellow).
- **History detail**: Show larger thumbnail or full image (if saved), flagged ingredients, and decision rationale.
- **Controls**: Provide options for *"Export history"*, *"Delete all history"*, and *"Delete image data"* for transparency and user control.

### Privacy Considerations
- Thumbnails are small, lightweight, and anonymized but are still treated as personal data.
- Full-size images are **opt-in only** and never synced by default.
- Users always retain full control, with simple **export and delete functionality** available in the app.

### Implementation Notes
- Store thumbnail path in `ScanHistoryEntry` model.
- Use `image` package for compression and resizing.
- Implement lazy loading in history list for smooth scrolling.
- Cache decoded thumbnails in memory (LRU) to avoid repeated decoding.
- Handle missing/corrupted images gracefully with placeholder.
- Provide storage usage information in settings (e.g., "History using 12.5 MB").

## Scanning UX Flow
1. **Camera View**: Real‑time subtle indicators (text boxes/animation) to reassure activity.
2. **Analysis Animation**: Short "thinking" animation (chameleon blinks/changes color) while rules/AI run.
3. **Result Screen**: Clear Vegan / Non‑Vegan / Uncertain + confidence. Expanders: "Detected ingredients", "Why this result?"
4. **Save to History**: Automatically save result with compressed thumbnail (and optionally full image if setting enabled).

### Accessibility
- Color + icon + text (color‑blind friendly).
- Screen reader labels for all controls and results.
- Haptic feedback on result changes.
- Text scaling support and high‑contrast mode.

## Barcode Fallback (Open Food Facts)
- Use when text scanning is difficult or to cross‑check popular products.
- Always show "Last updated: <date>" and allow reporting outdated data.
- Prefer OCR→AI; use barcode when available as a fast shortcut.
- When available, use Open Food Facts product image in history instead of captured thumbnail.

## Performance Requirements
- **Model optimization**: Quantize to INT8 where possible; prune/distill for older devices.
- **Model variants**:
  - **Nano** ~100–300 MB
  - **Standard** ~500–800 MB
  - **Full** ≥1 GB (post‑quantization target ~1–1.5 GB if needed)
- **Adaptive quality by RAM**:
  - >6 GB: Full Gemma 3n
  - 4–6 GB: Quantized/Standard
  - <4 GB: Nano/Distilled
- **Lazy loading**: Load model on first scan; keep warm between scans.
- **Frame skipping**: Process every 3rd frame (tunable).
- **Caching**: LRU for ~100 recent products/analyses.
- **Battery**: Reduce processing on low battery; prefer hardware delegates (NNAPI/Core ML).
- **Image storage**: Thumbnail compression to keep storage footprint minimal (~20–50 KB per scan).

## Database Strategy
- **Primary**: SQLite (`drift`), schema versioned with migrations.
- **Initial data**: Bundled seed; includes aliases/E‑numbers.
- **Updates**: Delta sync weekly on Wi‑Fi; manual refresh button.
- **Backups**: Optional cloud backup for history/favorites (thumbnails only; full images stay local).
- **History storage**: Store `ScanHistoryEntry` with thumbnail path; manage image files separately in app documents directory.

## Implementation Phases
### Phase 0 — Spikes
- Benchmark OCR on low/mid devices.
- Build text normalization pipeline.
- Prototype ≤300 MB model; measure load + inference.

### Phase 1 — MVP (Current Focus)
- Flutter app skeleton (Material 3).
- Camera integration + real‑time preview.
- ML Kit OCR.
- Rule‑based vegan detection + small DB (≈500 common ingredients).
- Explanations + uncertainty handling.
- **Scan history with compressed thumbnails**.
- Basic UI with instant visual feedback.

### Phase 2 — AI Integration
- Integrate Gemma 3n via TFLite/Core ML (multi‑variant models).
- Multimodal (image + text) reasoning.
- Extended DB (5 000+ ingredients).
- Confidence scoring & alternative suggestions.
- Full offline functionality with graceful fallbacks.
- **Optional full-size image storage setting**.

### Phase 3 — Polish & Scale
- Lottie mascot animations and fine‑tuned motion.
- i18n for 50+ languages + RTL support.
- Performance profiling & optimization.
- Beta testing, analytics, and app store prep (assets, descriptions).
- Device sync for history/favorites.
- **History export/import functionality**.

## Key Dependencies
```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^8.0.3
  injectable: ^2.5.0

  # Camera & OCR
  camera: ^0.11.0+2
  google_mlkit_text_recognition: ^0.14.0
  image: ^4.3.0

  # AI/ML (Phase 2)
  tflite_flutter: ^0.11.0

  # Database
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.27
  path_provider: ^2.1.5

  # UI
  lottie: ^3.2.1

  # Utils
  dartz: ^0.10.1
  intl: ^0.20.1

dev_dependencies:
  build_runner: ^2.4.15
  injectable_generator: ^2.6.2
  drift_dev: ^2.22.0
  flutter_lints: ^5.0.0
```
> Keep versions in sync with Flutter's current stable channel during upgrades.

## Critical Implementation Notes
### Flutter Specifics
- Use **StatefulWidget** for camera/scanning screens.
- Heavy processing in **Isolates**.
- **Lifecycle**: pause camera on background; resume safely.
- Use **SharedPreferences** for simple key‑value; **SQLite** for structured data.
- Never assume localStorage (web‑only).
- Image compression and thumbnail generation should be done in isolates to avoid UI jank.

### Camera & OCR Best Practices
- Use `CameraController` with appropriate resolution; lock focus when steady.
- Smart cropping based on text boundaries; pre‑resize for ML.
- Async frame processing to avoid UI jank.
- Graceful permission handling (Android & iOS).
- Flashlight toggle and exposure compensation.
- Capture high-quality frame for thumbnail before starting analysis.

### AI/ML Integration
- Lazy‑load model at first scan; show lightweight progress.
- Prefer quantization; fall back to rule‑based engine on errors.
- Cache common analyses; invalidate on model/DB version change.

### Performance Optimization
- Use `const` constructors; `ListView.builder` for long lists.
- Resize images before heavy ops; reuse buffers.
- Monitor memory with DevTools; `flutter run --profile` for profiling.
- Implement efficient thumbnail caching with LRU eviction.
- Use `CachedNetworkImage` pattern for history thumbnails.

## Testing Strategy
- **Unit**: Business logic, repositories, services, image compression utilities.
- **Widget**: UI components, BLoC states, history list rendering.
- **Integration**: Camera→OCR→Analysis→History workflow.
- **Golden**: UI consistency across devices/locales, history cards.
- **Performance**: FPS, memory, battery per 10 scans; storage footprint per 100 history entries.
- **Corpus testing**: Real packaging images with various distortions.

## Error Handling & Resilience
- Camera permission denial → graceful fallback with education.
- Network errors during sync → clear offline indicators.
- OCR failures (lighting/blur) → actionable tips and retry.
- DB errors → retry with exponential backoff.
- AI model load/inference errors → switch to rules + message.
- Thumbnail generation failures → save history without image; show placeholder.
- Storage full → warn user; offer to clean up old history/images.

## Accessibility
- Screen reader labels for all interactive elements.
- High‑contrast theme and scalable typography.
- Haptics on result state changes.
- Alternative text for images/animations.
- History thumbnails have proper content descriptions.

## Internationalization (Phase 3)
- 50+ languages (align with OCR support).
- RTL support (Arabic, Hebrew).
- Localized ingredient names and rationale.
- Regional rule awareness (EU/US/other).

## Security & Privacy
- No account required; privacy‑first defaults.
- On‑device processing by default; explicit opt‑in for any cloud feature.
- No tracking without consent.
- Open source ingredient database; cite sources in entries.
- Do not imply official certification; always show disclaimer.
- Trademarks visible only for local analysis (no redistribution).
- **History images**: Thumbnails treated as personal data; full images are opt-in only.
- **User control**: Simple export and delete functionality for all history data.
- **Sync privacy**: Only thumbnails synced with E2EE; full images never leave device.

## Development Workflow
### Repository & Branching
- GitHub: `https://github.com/Erik-Edward/Vegolo` (main protected).
- Feature branch flow with PR reviews.

### Git Workflow
1. Create feature branch: `git checkout -b feature/<slug>`
2. Commit frequently with descriptive messages.
3. Push: `git push origin feature/<slug>`
4. Open PR; request tests with implementation.
5. Merge to `main` after approval & CI green.

### Conventional Commits
- `feat:` new features (e.g., `feat: add history with thumbnails`)
- `fix:` bug fixes (e.g., `fix: handle null camera controller`)
- `docs:` documentation
- `refactor:` internal changes
- `test:` add/improve tests
- `chore:` maintenance

### CI & Quality Gates
- Automated tests on PR.
- Performance budgets (min FPS, max memory).
- Linting + formatting; golden tests for key screens.

### .gitignore (Flutter)
- Standard Flutter/Android/iOS ignores.
- Exclude model binaries and seed DB sources as appropriate (use release artifacts).

## Key Metrics
- **Time‑to‑first‑result** (ms)
- **Share of "uncertain" results**
- **User correction reports**
- **Battery per 10 scans**
- **Crash‑free sessions**
- **History storage footprint** (MB per 100 entries)
- **Thumbnail load time** (ms)

## Current Phase
**Phase 1 — MVP**: Build a solid baseline with camera + OCR + rule‑based engine + history with thumbnails, then layer AI (Phase 2).