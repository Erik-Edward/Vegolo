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

- `ModelManager` now orchestrates manifest caching, RAM-based variant selection, and native load/unload via `GemmaRuntimeChannel`.
- Device RAM heuristics: highest variant whose `min_ram_gb` fits the reported RAM, fallback to smallest bundle when below min spec.
- Placeholders remain for:
  1. Wi-Fi-only download + checksum verification.
  2. Extracting archives into an mmap-friendly directory (expected: `ApplicationSupportDirectory/gemma/<variant>`).
  3. KV-cache warm-up prompt (invoked through `GemmaRuntimeChannel.generate`).
- Active model/tokenizer paths are cached for reuse by the tokenizer pipeline and exposed via getters.

## Android LiteRT-LM Bridge

- Channel: `vegolo/gemma`.
- Methods:
  - `loadVariant(variantId, modelPath, tokenizerPath)` – loads interpreter (stubbed today).
  - `unload()` – releases interpreter, clears caches.
  - `isReady()` – returns `{ loaded: bool, variantId: string? }`.
  - `generate(prompt, maxTokens, temperature, topP, timeoutMillis)` – executes inference (currently returns placeholder payload and logs latency).
- Telemetry: logcat (`VegoloGemmaService`) records load/unload requests, requested variants, and latency for each `generate` call. Final integration will add failure codes / bail-out reasons.
- Pending: LiteRT-LM interpreter wiring, delegate selection (NNAPI vs CPU), KV cache priming, and streaming/token budget enforcement.

## Tokenizer Pipeline

- Placeholder `PlaceholderGemmaTokenizer` (ASCII split) unblocks call sites until SentencePiece assets ship.
- Factory: `createGemmaTokenizer(tokenizerPath)` will be swapped for a real SentencePiece binding (likely native via MethodChannel or Dart FFI).
- Artifact placement expectation:
  - `.model` file extracted next to the `.tflite` inside `ApplicationSupportDirectory/gemma/<variant>/tokenizer.model`.
  - Model manifest entry points at the relative path within the archive; `ModelManager` will translate to absolute path during extraction.
- TODO: confirm redistribution rights and delivery of Gemma 3n SentencePiece model; add checksum to manifest once pinned.

## Analysis Flow (`PerformScanAnalysis`)

- Rule-first decision remains authoritative for deterministic non-vegan hits (flagged ingredients).
- Configured uncertainty threshold: AI consulted when rule-based confidence < `0.75`.
- Currently AI toggle is disabled (`AiAnalysisConfig.aiEnabled = false`) until the runtime is verified; flip the flag once the LiteRT-LM path is stable.
- Fallback rules:
  - AI failure (`null` or `PlatformException`) keeps rule result intact.
  - AI success merges alternatives and flagged ingredients, preferring AI-specific findings.

## Telemetry & Debugging

- Dart-side logs surface through `debugPrint` for load contention and AI errors.
- Android logcat (tag `VegoloGemmaService`) captures load/unload requests, requested paths, and per-inference latency.
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
