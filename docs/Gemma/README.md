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
  "artifacts_base_url": "https://download.example.com/vegolo/gemma3n/",
  "variants": [
    {
      "id": "nano",
      "min_ram_gb": 3.0,
      "recommended_ram_gb": 4.0,
      "quantization": "int8-dynamic",
      "archive_sha256": "TBD",
      "files": [
        {"type": "model", "path": "gemma_3n/nano/gemma-3n-nano-int8.tflite"},
        {"type": "tokenizer", "path": "tokenizers/gemma-3n-tokenizer.model"}
      ]
    }
  ]
}
```

- TODO: replace `"TBD"` checksums, real sizes, and final CDN base URL once artifacts land.

## Model Lifecycle (Dart)

- `ModelManager` orchestrates manifest caching, RAM-based variant selection, and native load/unload via `GemmaRuntimeChannel`.
- Device RAM heuristics: highest variant whose `min_ram_gb` fits the reported RAM, fallback to smallest bundle when below min spec.
- **Download + extraction implemented**:
  - Models/tokenizer (or a zipped archive) are downloaded into
    `ApplicationSupportDirectory/vegolo/gemma3n/<variant>`.
  - SHA-256 and size are enforced against the manifest; digest sidecars
    (`*.sha256`) prevent repeated hashing.
  - Archives (zip) are re-used via an `.archive_extracted` marker and are
    extracted with path traversal protection.
- The fully-qualified file paths are now cached for reuse by the tokenizer
  pipeline and surfaced via `activeModelPath` / `activeTokenizerPath`.
- Still pending: KV-cache warm-up prompt (invoked through
  `GemmaRuntimeChannel.generate`).

## Android LiteRT-LM Bridge

- Channel: `vegolo/gemma`.
- Methods:
  - `loadVariant(variantId, modelPath, tokenizerPath, options)` – validates
    file existence and captures runtime preferences (threads, NNAPI, default
    timeout). The interpreter is still stubbed but the contract is ready.
  - `unload()` – releases interpreter, clears caches.
  - `isReady()` – returns `{ loaded: bool, variantId: string? }`.
  - `generate(prompt, maxTokens, timeoutMillis)` – runs on a single-thread
    executor, returns latency, timeout, or error reasons; placeholder text is
    still empty until LiteRT-LM wiring lands.
- Telemetry: logcat (`VegoloGemmaService`) records load/unload requests,
  requested paths, options, and per-inference latency. The skeleton already
  handles request timeouts and non-fatal errors.
- Pending: LiteRT-LM interpreter wiring (google-ai-edge/LiteRT-LM), delegate
  selection (NNAPI vs CPU), KV cache priming, and streaming/token budget
  enforcement.

## Tokenizer Pipeline

- `createGemmaTokenizer` still returns a placeholder but now resolves the
  tokenizer path emitted by `ModelManager`, i.e. the extracted
  `tokenizers/gemma-3n-tokenizer.model` under the support directory.
- TODO: confirm redistribution rights and delivery of Gemma 3n SentencePiece
  model; add checksum to manifest once pinned.

## Analysis Flow (`PerformScanAnalysis`)

- Rule-first decision remains authoritative for deterministic non-vegan hits.
- Configured uncertainty threshold: AI consulted when rule-based confidence < `0.75`.
- **Settings toggle implemented**: the AI path is gated by
  `SettingsRepository.getAiAnalysisEnabled()`. Users can control it from
  Settings → “Enable AI analysis (Gemma 3n)”.
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
- Planned additions (Phase 2 follow-up):
  1. Structured telemetry sink (e.g., `Timber` + logcat filters) for development builds.
  2. Counters for rule-only fallback reasons (timeout, model not loaded, tokenizer missing).
  3. Battery/RAM sampling hook before/after load to validate guardrails.

## Acceptance Fixtures (Planned)

1. **Rules passthrough** – Known vegan/non-vegan ingredient lists to assert AI is not consulted when confidence ≥ 0.75.
2. **AI rescue** – Synthetic OCR blob with ambiguous wording; mock Gemma response to ensure merged output adjusts confidence and alternatives.
3. **Timeout fallback** – Simulate `generate` timeout and validate rule result persists, telemetry records fallback.
4. **Tokenizer missing** – Force manifest without tokenizer entry to assert descriptive error surfaced and rule result holds.

Fixtures will live under `test/fixtures/gemma/` once tokenizer + runtime land; tests will inject a fake `GemmaService` to emulate native responses deterministically.

## Outstanding Items / Open Questions

1. **Tokenizer artefact** – Need Gemma 3n `.spm`/`.model` file + redistribution clearance.
2. **Reference LiteRT-LM sample** – Pin `google-ai-edge/MediaPipe GenAI` commit for inference scaffolding and delegate configuration guidance.
3. **Model delivery** – Decide between Play Asset Delivery vs. Play for On-device AI for Android; define checksum workflow and retention policy. Mirror plan for iOS ODR/app thinning.
4. **License & attribution** – Finalize Gemma 3/3n licensing copy for settings/about screens.
5. **RAM detection** – Source of truth for device RAM (Android: `ActivityManager.MemoryInfo`, iOS equivalent) to replace the current placeholder default.

---

### Reference Library

All upstream research material (Gemma model card, tokenizer spec, LiteRT-LM guides, Core ML planning, quantization notes) remains unchanged inside this directory and `docs/Gemma3n/`. Consult them as needed during implementation.
