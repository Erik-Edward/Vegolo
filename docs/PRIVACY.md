# Vegolo Telemetry & Analytics Policy

Vegolo is designed as an offline-first app. Telemetry remains optional and
privacy-preserving. This document summarises what we collect, when, and how
users stay in control.

## Data Collected (Telemetry Opt-in)
When the user enables “Share anonymous Gemma telemetry” in Settings, the app
may upload the following fields per session:

| Field | Type | Purpose | Notes |
|-------|------|---------|-------|
| `variant` | string | Device model variant used (nano/standard/full) | No device identifiers |
| `status` | string (enum) | Outcome of an inference (success, timeout, cancelled, error, parse_failure) | Indicates reliability |
| `prompt_length` | int | Characters sent to Gemma | Aggregated only; no raw OCR text |
| `response_length` | int | Characters in Gemma output | No content of response uploaded |
| `ttft_ms` | int | Time-to-first-token in milliseconds | Helps track performance |
| `latency_ms` | int | Total inference latency | Performance metric |
| `finish_reason` | string? | Optional reason for stream completion | e.g., “timeout” |
| `totals.total` | int | Aggregate number of inferences this session | |
| `totals.success` | int | Count of successful inferences | |
| `totals.timeout` | int | Count of timeouts | |
| `totals.cancelled` | int | Count of user/system cancellations | |
| `totals.error` | int | Count of errors | |
| `totals.parse_failure` | int | Count of parse failures | |
| `totals.avg_ttft_ms` | double? | Rolling average TTFT | |
| `totals.avg_latency_ms` | double? | Rolling average latency | |

No ingredient text, OCR content, product images, or personal identifiers are
sent. Uploads happen over HTTPS when connectivity is available.

## User Controls
- **Opt-in toggle** lives at Settings → “Share anonymous telemetry.” Disabled by
default. Users can opt out anytime; subsequent uploads stop immediately.
- **Offline mode:** the app queues nothing if the user opts out or is offline.
- **Clear data:** clearing application data or uninstalling removes all local
telemetry state.

## Retention & Use
- Telemetry is stored in aggregated form for performance monitoring and product
reliability analysis.
- No advertising use, no user profiling.
- Internal access is restricted to engineering/QA for debugging trends.
- Data is retained for a maximum of 180 days before being rolled into anonymised
trend reports.

## Compliance & Security
- Transport uses TLS 1.2+.
- We recommend deploying exporters to servers that comply with GDPR/CCPA if you
ship to affected regions.
- Any change to the telemetry payload or retention requires updating this
document and the in-app legal copy.

## Contact
Questions about telemetry or privacy? Reach out at privacy@vegolo.app.
