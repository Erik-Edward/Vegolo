# Vegolo Telemetry Pipeline

Vegolo keeps inference diagnostics local by default. The new `TelemetryService`
collects Gemma inference summaries and exposes them through a `ValueListenable`.
That allows the scanning UI (debug builds) to show live metrics while
production builds can remain silent.

## Export Hooks
- Call `getIt<TelemetryService>().registerExporter(...)` from an initialization
  point (e.g., `main.dart` after DI setup).
- Implement `TelemetryExporter` (see `AnalyticsTelemetryExporter`) to forward
  `GemmaInferenceEvent` data to your analytics SDK. The exporter receives both
  the raw event and the aggregated `GemmaTelemetrySummary` so you can batch
  uploads.
- Use `TelemetryUploader` to encapsulate the actual transport. The default
  `NoopTelemetryUploader` keeps everything local; swap in an HTTP uploader when
  the backend is ready.
- Runtime credentials are supplied via `--dart-define=TELEMETRY_ENDPOINT=...`
  and `--dart-define=TELEMETRY_API_KEY=...`. The app also reads
  `--dart-define=APP_VERSION=<semver>` (defaults to `dev` if omitted).
  Release builds throw if endpoint or API key are missing.
- Dev commands:
  - `flutter run --dart-define=TELEMETRY_ENDPOINT=https://telemetry.vegolo.app/v1/gemma \
      --dart-define=TELEMETRY_API_KEY=vegolo-dev-telemetry-key \
      --dart-define=APP_VERSION=1.0.0-dev`
  - `flutter test --dart-define=TELEMETRY_ENDPOINT=https://telemetry.vegolo.app/v1/gemma \
      --dart-define=TELEMETRY_API_KEY=vegolo-dev-telemetry-key \
      --dart-define=APP_VERSION=1.0.0-dev`
  Update CI/launch configs with the same flags.
- Uploads retry automatically up to 3 attempts with exponential backoff when
  the server returns 5xx/429 or the device is temporarily offline. The final
  attempt propagates the error for visibility in logs.
- Ship exporters selectively: wire in a `NoopTelemetryExporter` when analytics
  is disabled, or gate registration on a remote config flag/user consent.

## Suggested Analytics Payload
```
{
  "variant": summary.lastEvent?.variantId,
  "total": summary.total,
  "success_rate": summary.success / summary.total,
  "timeout_rate": summary.timeout / summary.total,
  "avg_ttft_ms": summary.averageTtftMs,
  "avg_latency_ms": summary.averageLatencyMs
}
```
Emit this no more than once per session (e.g., when the user leaves the
scanning screen) to limit network usage.

## Privacy Notes
- Do not include OCR text or product identifiers in telemetry payloads.
- Respect Vegolo's offline-first policy: queue telemetry until the device has
  connectivity, and honor opt-in/out preferences from `SettingsRepository`.
- Telemetry payload schema and retention details are maintained in `docs/PRIVACY.md`.

## Local Debugging
- In debug builds, the analytics icon in the scanning page toggles a summary card
  sourced from `TelemetryService`. Production builds hide the control.
- You can also attach a quick logging exporter during development: call
  `registerExporter(DebugLogTelemetryExporter())` and log to Logcat.
