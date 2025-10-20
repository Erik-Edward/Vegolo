# Telemetry Exporter Playbook

Vegolo’s telemetry pipeline now supports pluggable exporters. This playbook
covers how to enable a real analytics sink safely.

## 1. Register the exporter
After `configureDependencies()` completes (see `main.dart`), resolve the
`TelemetryService` and register the analytics exporter:

```dart
final telemetry = getIt<TelemetryService>();
final exporter = getIt<AnalyticsTelemetryExporter>();
telemetry.registerExporter(exporter);
```

## 2. Respect opt‑in/consent
Configure `SettingsRepository` to persist a boolean preference via
`setTelemetryAnalyticsEnabled()`. Only register the exporter (or let it send)
when users have opted in. The provided `AnalyticsTelemetryExporter` checks the
flag on every event and can be told to refresh via `invalidateOptInCache()`.

The exporter also consumes runtime configuration from `TelemetryConfig`, which
is sourced from dart-defines:

```
flutter run --dart-define=TELEMETRY_ENDPOINT=https://telemetry.vegolo.app/v1/gemma \
             --dart-define=TELEMETRY_API_KEY=your_api_key_here
```

## 3. Emit aggregated payloads
`AnalyticsTelemetryExporter` receives both the latest event and the aggregated
`GemmaTelemetrySummary`. Batch uploads (e.g., send once per session or when the
user exits scanning) to reduce network usage. It delegates network delivery to
`TelemetryUploader`, which you can replace with an HTTP implementation.

Suggested normalized payload:
```
{
  "variant": event.variantId,
  "status": event.status.name,
  "prompt_length": event.promptLength,
  "response_length": event.responseLength,
  "ttft_ms": event.ttftMs,
  "latency_ms": event.latencyMs,
  "finish_reason": event.finishReason,
  "totals": {
    "total": summary.total,
    "success": summary.success,
    "timeout": summary.timeout,
    "cancelled": summary.cancelled,
    "error": summary.error,
    "parse_failure": summary.parseFailure,
    "avg_ttft_ms": summary.averageTtftMs,
    "avg_latency_ms": summary.averageLatencyMs
  }
}
```
Sanitize before upload (remove nulls, clamp values) based on your analytics SDK
requirements.

## 4. Privacy and retention
- Include a toggle in settings (already in place) and respect it at runtime.
- Log uploads (tagged `analytics/gemma`) for QA; disable logging in production.
- Reference `docs/PRIVACY.md` for the up-to-date payload schema and retention policy.
- Ensure uploads occur only on secure channels (HTTPS) and obey offline mode.

## 5. Testing checklist
1. Enable telemetry in settings.
2. Confirm exporter prints debug payloads locally.
3. Flip the toggle off; payloads should stop.
4. Simulate background/foreground transitions to ensure batching logic works.
5. Add integration tests that register a spy exporter and assert it receives
   events when opt-in is true.

By following this playbook, you can connect Vegolo’s on-device telemetry to
production analytics while keeping privacy controls front and center.
