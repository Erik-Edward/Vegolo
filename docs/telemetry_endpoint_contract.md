# Vegolo Telemetry Endpoint Contract (Draft)

This document defines the proposed HTTP contract for uploading Gemma telemetry
from the Vegolo app. The contract can be implemented by any backend service
(Cloud Function, API Gateway, etc.) and should be reviewed before production
deployment.

## Endpoint Summary
- **Method:** POST
- **URL:** `https://telemetry.vegolo.app/v1/gemma`
- **Headers:**
  - `Content-Type: application/json`
  - `Authorization: Bearer <token>` (static API key or signed JWT)
  - `X-Client-Version: <semver>` (Vegolo app version)
  - `X-Session-Id: <UUID>`
- **Timeout:** 5 seconds client-side
- **Retry Policy:** at most 2 retries with exponential backoff (handled on the client)
- **Authentication:**
  - Prefer a short-lived signed token (e.g., JWT) issued at build time or via remote config.
  - For MVP, a static API key is acceptable if rotated regularly and stored securely on device.
- **Rate Limit:** target ≤ 200 requests/user/day (client batches telemetry; endpoint may enforce additional limits).

## Request Payload
Example JSON payload (fields sanitized to remove nulls):

```json
{
  "app_version": "1.3.0",
  "variant": "nano",
  "status": "success",
  "prompt_length": 480,
  "response_length": 220,
  "ttft_ms": 180,
  "latency_ms": 420,
  "finish_reason": "completed",
  "totals": {
    "total": 25,
    "success": 22,
    "timeout": 2,
    "cancelled": 1,
    "error": 0,
    "parse_failure": 0,
    "avg_ttft_ms": 210.5,
    "avg_latency_ms": 510.2
  },
  "session_id": "a4c3d71d-5a0b-4e59-9a6d-8af23edddc21",
  "sent_at": "2025-02-18T12:34:56.789Z"
}
```

### Field Notes
- `variant`: one of `nano`, `standard`, `full`.
- `status`: matches the GemmaInferenceStatus enum (`success`, `timeout`, `cancelled`, `error`, `parse_failure`).
- `prompt_length` / `response_length`: integer character counts (no raw text included).
- `ttft_ms`, `latency_ms`: integers in milliseconds. Omitted if unavailable.
- `finish_reason`: optional string (e.g., `timeout`, `success`).
- `totals`: aggregate session counters/averages (payload stripped of null values by client).
- `session_id`: UUID generated per app session/day to help deduplicate events server-side.
- `sent_at`: ISO8601 timestamp in UTC when the payload is sent.

## Response
- **Success:** HTTP 202 with optional body `{ "accepted": true }`.
- **Client Error:**
  - 400 Bad Request (malformed payload) – respond with validation errors.
  - 401 Unauthorized – invalid/expired token.
  - 429 Too Many Requests – include `Retry-After` header.
- **Server Error:**
  - 500-series codes when unable to process; client may retry after backoff.

Example success response:
```json
{
  "accepted": true,
  "receipt_id": "8bf86930-453b-4cf1-aeef-96a5f8880bc0"
}
```

## Validation Rules
- Payload must be valid JSON and under 10 KB.
- Required fields: `variant`, `status`, `totals.total`, `session_id`, `sent_at`.
- `variant` must be one of the known values.
- Numeric fields must be non-negative.
- Server should reject requests missing `Authorization` or with invalid tokens.

## Security Considerations
- Always enforce HTTPS.
- Implement rate limiting per API key/session to mitigate abuse.
- Log accepted/rejected events with minimal metadata for monitoring.
- Rotate API keys or signing secrets regularly.
- Consider signing payloads (e.g., HMAC) if additional integrity is required.

## Next Steps
1. Backend engineers review and confirm feasibility.
2. Provision endpoint + authentication.
3. Replace `NoopTelemetryUploader` with an HTTP implementation that targets this contract.
4. Update app configuration (`TelemetryConfig`) with the real endpoint and token acquisition logic.
