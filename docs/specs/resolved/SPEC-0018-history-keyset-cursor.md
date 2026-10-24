# SPEC-0018: History Keyset Cursor

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-019: history pagination never skips or repeats entries.

## Current Behavior
`GET api/subaccounts/history` turns the cursor into a JS `Date` (milliseconds only) and
`api_subaccount_history` filters `created_at < cursor` with no tie-break, so entries sharing a
timestamp at a page boundary are skipped.

## Desired Behavior
The cursor is opaque: `"<created_at, full precision>|<id>"` of the last returned entry. The RPC
parses and validates it (invalid → 400) and filters `(created_at, id) < (cursor_ts, cursor_id)`,
matching the `created_at desc, id desc` order. The Edge Function passes it through.

## Scope
Migration (`p_cursor` becomes `text`, revoke/grant repeated); `handleSubaccountHistory`; QA test;
API contract. The client already treats the cursor as an opaque string.

## Acceptance Criteria
- [x] Entries with an identical timestamp are all returned once across pages; invalid cursor → 400.

## Verification
`qa/run.sh qa/api/history_analytics.test.ts`

## Documentation Updates
`docs/contracts/api-surface.md`, `docs/qa/findings.md`.

## Rollout Notes
`supabase db push`, deploy `api`. A page request in flight during the deploy may get one 400.
