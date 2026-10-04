# SPEC-0014: Assets List Requires Kind

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-018: `GET api/assets/list` only lists one `kind`, so a single page is always correct.

## Current Behavior
`kind` is optional; without it the 100-row page of a 200-asset catalog sorted by kind contains only
crypto. The API also maps an invalid `kind` silently to "all". All client calls pass `kind`.

## Desired Behavior
`api_list_assets` requires `kind` (`fiat`/`crypto`); missing or invalid → `VALIDATION_ERROR` (400).
The Edge Function passes the query param through; the RPC is the single validation point.

## Scope
Migration recreating `api_list_assets`; `handleAssetsList`; QA test; API contract.

## Out Of Scope
Pagination of the catalog (QA-027).

## Acceptance Criteria
- [x] Missing or invalid `kind` returns 400; `fiat`/`crypto` unchanged.

## Verification
`qa/run.sh` (assets suite) after deploy.

## Documentation Updates
`docs/contracts/api-surface.md`, `docs/qa/findings.md`.

## Rollout Notes
`supabase db push`, deploy `api`.
