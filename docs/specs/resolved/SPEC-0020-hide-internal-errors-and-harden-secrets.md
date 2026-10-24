# SPEC-0020: Hide Internal Errors And Harden Secrets

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-025: clients never see raw database errors; secrets are compared in constant time;
`rates_sync` only runs on POST.

## Current Behavior
`fromError` returns any non-`ApiHttpError` with its message, `code`, `details` and `hint`, and
`parseDbError` wraps unmapped database messages into a 500 with the raw text. Webhook and scheduler
secrets are compared with `!==`. `rates_sync` runs on any method.

## Desired Behavior
- `fromError` is the single rule: `ApiHttpError` below 500 is returned as raised; everything else
  is logged server-side with its details and answered as `{code, message: "Internal error"}`
  (the `ApiHttpError` code is kept, `INTERNAL_ERROR` otherwise).
- `_shared/secrets.ts` `secretsEqual` (SHA-256 both, constant-time compare) is used by
  `revenuecat_webhook` and `rates_sync`.
- `rates_sync` answers non-POST with 404, like the webhook.

## Out Of Scope
CORS `*`: auth is a Bearer token (no cookies) and the client is a mobile app, so a wildcard origin
does not expose anything.

## Acceptance Criteria
- [x] Unit tests for `fromError` and `secretsEqual`.
- [x] Full `qa/run.sh` green after deploy; `rates_sync` GET → 404.

## Verification
`deno test --allow-env backend/supabase/functions/_shared/`, `qa/run.sh`.

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Deploy `api`, `revenuecat_webhook`, `rates_sync` (the last two with `--no-verify-jwt`).
