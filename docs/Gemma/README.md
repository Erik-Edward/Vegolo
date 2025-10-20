# Vegolo Gemma 3n Integration — Sprint 1 Notes

This document tracks the Phase 2 scaffolding delivered in this iteration and records the open questions left to unblock full LiteRT-LM integration. All prior reference PDFs/blog posts remain inside `docs/Gemma/` and `docs/Gemma3n/`; this README now anchors Vegolo-specific decisions.

---

## Manifest & Artifact Layout

- Source of truth: `lib/core/ai/model_manifest.json` (bundled via `pubspec.yaml`).
- Loader: `ModelManifestLoader` validates structure, ensures checksums, and exposes variant metadata to `ModelManager`.
- Schema highlights:

```jsonc
{
  "schema_version": 1,
  "generated_at": "2024-10-01T00:00:00Z",
  "artifacts_base_url": "https://cdn.vegolo.app/gemma3n/v1/",
  "variants": [
    {
      "id": "nano",
      "min_ram_gb": 3.0,
      "recommended_ram_gb": 4.0,
      "quantization": "int4",
      "compression": "none",
      "archive_sha256": "TBD",
      "files": [
        {"type": "model", "path": "models/gemma-3n-e2b-it-int4-web.litertlm"},
        {"type": "tokenizer", "path": "tokenizers/gemma-3n-tokenizer.model"}
      ]
    }
  ]
}
```
- The production manifest mirrors the official LiteRT-LM `.litertlm` payloads to Vegolo's CDN (`https://cdn.vegolo.app/gemma3n/v1/`) and pins their SHA-256 checksums. Nano targets the E2B `int4-web` build; Standard and Full consume the E4B `int4` variants.
- Tokenizer delivery remains centralised: the shared SentencePiece model is validated once (checksum `ea5f0cc4…`) and copied into each variant directory after download.
- Archive metadata is updated via `dart tool/update_gemma_manifest.dart`, which accepts the Nano/Standard/Full `.zip` artefacts, computes SHA-256 + sizes, and rewrites `lib/core/ai/model_manifest.json` alongside the documentation snippet in this file. Run with `--dry-run` to verify paths and checksums before committing.

## Model Lifecycle (Dart)

- `ModelManager` orchestrates manifest caching, RAM-based variant selection, and native load/unload via `GemmaRuntimeChannel`.
- Device RAM heuristics: highest variant whose `min_ram_gb` fits the reported RAM, fallback to smallest bundle when below min spec.
- **Download + verification implemented**:
  - `.litertlm` model bundles and the tokenizer are downloaded into
    `ApplicationSupportDirectory/vegolo/gemma3n/<variant>`.
  - SHA-256 and size are enforced against the manifest; digest sidecars
    (`*.sha256`) prevent repeated hashing.
  - When a checksum fails, the manager re-downloads the artefact from the CDN
    and refuses to load the model until verification succeeds.
- The fully-qualified file paths are now cached for reuse by the tokenizer
  pipeline and surfaced via `activeModelPath` / `activeTokenizerPath`.
- Warm-up now sends a 1-token streaming prompt to prime the interpreter and
  logs TTFT/latency telemetry for visibility during development builds.

## Android LiteRT-LM Bridge

- Channel: `vegolo/gemma`.
- Methods:
  - `loadVariant(variantId, modelPath, tokenizerPath, options)` – validates
    file existence, captures runtime preferences (threads, backend, default
    timeout), and now instantiates the MediaPipe Tasks **LLM Inference** engine
    (`com.google.mediapipe:tasks-genai:0.10.27`).
  - `unload()` – releases interpreter, clears caches.
  - `isReady()` – returns `{ loaded: bool, variantId: string? }`.
  - `generate(prompt, maxTokens, timeoutMillis)` – now delegates to
    `generateResponseAsync`, capturing TTFT and full latency metrics while
    returning the concatenated response.
  - `generateStream(streamId, prompt, …)` – starts streaming partial tokens over
    an `EventChannel` (`vegolo/gemma_stream`) with delta updates, TTFT, and
    final latency/finish reasons.
  - `cancelStream(streamId)` – cancels the active decode, returning the partial
    buffer with a `reason` of `cancelled`.
- Telemetry: logcat (`VegoloGemmaService`) records load/unload requests,
  requested paths, options, TTFT, and per-inference latency. Stream lifecycle
  events log successes, timeouts, cancellations, and failures.
- Per-call decode overrides (maxTokens, temperature, topK, topP, randomSeed)
  are accepted from Flutter and applied to `LlmInferenceSessionOptions`.

## Tokenizer Pipeline

- `createGemmaTokenizer` resolves the tokenizer path emitted by `ModelManager`,
  using the mirrored SentencePiece artefact once it has been verified against
  the pinned checksum (`ea5f0cc4…`).
- Redistribution requirements are documented in-app via the Settings → Gemma
  legal notices sheet (see `GEMMA_LEGAL_NOTICES.txt`).

## Analysis Flow (`PerformScanAnalysis`)

- Rule-first decision remains authoritative for deterministic non-vegan hits.
- Configured uncertainty threshold: AI consulted when rule-based confidence < `0.75`.
- **Settings toggle implemented**: the AI path is gated by
  `SettingsRepository.getAiAnalysisEnabled()`. Users can control it from
  Settings → “Enable AI analysis (Gemma 3n)”.
- Generation preferences (max tokens, temperature, topK/topP, optional seed)
  live in Settings → “Gemma generation settings” and flow through
  `PerformScanAnalysis` into the Dart ↔ Kotlin bridge for every request.
- Fallback rules:
  - AI failure (`null` or `PlatformException`) keeps rule result intact.
  - AI success merges alternatives and flagged ingredients, preferring AI
    findings.

### Tests

- New unit coverage in `test/features/scanning/domain/perform_scan_analysis_test.dart`
  verifies:
  1. AI disabled → Gemma never invoked.
  2. AI enabled + uncertain rule result → Gemma invoked and result merged.
  3. Deterministic non-vegan rule decision stays authoritative even when AI is on.

## Telemetry & Debugging

- Dart-side logs surface through `debugPrint` for load contention and AI errors.
- Android logcat (tag `VegoloGemmaService`) captures load/unload requests,
  options, requested paths, and per-inference latency/timeout/error reasons.
- New `TelemetryService` abstraction (default `DebugTelemetryService`) records
  Gemma inference outcomes (status, TTFT, latency, finish reason, response size)
  so the sink can be swapped for production analytics without code churn.
- Scanning UI now includes a debug-only telemetry panel (analytics icon appears only in dev builds) that listens to the `TelemetryService` summary and surfaces counts/averages in real time.
- See `docs/TELEMETRY_PIPELINE.md` for production exporter integration guidance.
- Planned additions (Phase 2 follow-up):
  1. Wire `TelemetryService` into the production analytics/metrics pipeline and
     define retention/PII guidance.
  2. Counters for rule-only fallback reasons (timeout, model not loaded,
     tokenizer missing).
  3. Battery/RAM sampling hook before/after load to validate guardrails.

## Acceptance Fixtures (Planned)

1. **Rules passthrough** – Known vegan/non-vegan ingredient lists to assert AI is not consulted when confidence ≥ 0.75.
2. **AI rescue** – Synthetic OCR blob with ambiguous wording; mock Gemma response to ensure merged output adjusts confidence and alternatives.
3. **Timeout fallback** – Simulate `generate` timeout and validate rule result persists, telemetry records fallback.
4. **Tokenizer missing** – Force manifest without tokenizer entry to assert descriptive error surfaced and rule result holds.

Fixtures will live under `test/fixtures/gemma/` once tokenizer + runtime land; tests will inject a fake `GemmaService` to emulate native responses deterministically.

## Outstanding Items / Open Questions

1. **CDN mirroring** – Automate validation + promotion of new LiteRT-LM artefacts when Google refreshes Gemma 3n builds.
2. **Reference LiteRT-LM sample** – Pin `google-ai-edge/MediaPipe GenAI` commit for inference scaffolding and delegate configuration guidance.
3. **Model delivery** – Decide between Play Asset Delivery vs. Play for On-device AI for Android; define checksum workflow and retention policy. Mirror plan for iOS ODR/app thinning.
4. **Attribution automation** – Keep the in-app Gemma legal notice synced with upstream wording when Google updates the Terms or Prohibited Use policy.
5. **RAM detection** – Source of truth for device RAM (Android: `ActivityManager.MemoryInfo`, iOS equivalent) to replace the current placeholder default.

---

### Reference Library

All upstream research material (Gemma model card, tokenizer spec, LiteRT-LM guides, Core ML planning, quantization notes) remains unchanged inside this directory and `docs/Gemma3n/`. Consult them as needed during implementation.
