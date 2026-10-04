# SPEC-0013: RevenueCat Transfer Webhook

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-007: a `TRANSFER` webhook updates both sides instead of failing with 400.

## Current Behavior
The webhook requires `event.app_user_id`; `TRANSFER` has `transferred_from`/`transferred_to`
instead, so it returns 400 and the previous owner keeps `pro` until they open the app.

## Desired Behavior
- "Reconcile one user from RevenueCat REST" lives in `_shared/revenuecat_sync.ts` and is used by
  `POST /revenuecat/refresh` and by the webhook for `TRANSFER`.
- `TRANSFER` reconciles every id in `transferred_from` + `transferred_to` (deduped, anonymous ids
  skipped) and answers 200; users without a profile are reported, not retried.
- Other events keep the current path.

## Out Of Scope
Store/environment filtering (BL-0002).

## Acceptance Criteria
- [x] Synthetic `TRANSFER` returns 200 (`billing_security.test.ts`).
- [x] `/revenuecat/refresh` behavior unchanged (429 → keep plan).

## Verification
- `deno test --allow-env backend/supabase/functions/revenuecat_webhook/index_test.ts`
- `qa/run.sh qa/api/billing_security.test.ts`
- Device case R2 (owner).

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Deploy `api` and `revenuecat_webhook` (`--no-verify-jwt`).

## Resolution Notes
- Device case R2 (real transfer between two app users) remains an owner check.
