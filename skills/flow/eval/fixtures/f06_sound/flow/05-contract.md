# 05 — Contract

## Interfaces

| Method | Path | Request | Response | Errors | Owner |
|---|---|---|---|---|---|
| GET | /healthz | none | `{ "ok": true }` | 503 if deps down | platform |
| GET | /api/orders | `?since=<iso8601>` | `{ "orders": [...] }` | 400 bad `since`; 401 | orders |
| POST | /api/orders | order JSON body | `{ "id": "ord-..." }` | 400 invalid body; 401; 409 duplicate | orders |

## Auth

- Public: `/healthz` only.
- All other routes: bearer session token; 401 if missing/invalid.

## Error model

- `code` (string), `message` (string), `request_id` (string).
- 4xx client; 5xx server; no silent 200 on failure.

## Gate
- [x] Every endpoint has method, path, request, response, errors, owner.
- [x] Auth boundary is explicit for each route class.
- [x] Error shape is machine-readable and stable.
