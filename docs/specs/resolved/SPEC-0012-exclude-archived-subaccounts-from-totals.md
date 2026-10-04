# SPEC-0012: Exclude Archived Subaccounts From Totals

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-020 with one rule: archived accounts and archived subaccounts are not counted in any total.

## Current Behavior
`api_list_accounts` live total excludes archived subaccounts; `recompute_account_cached_total_usd`
includes them; `api_analytics_summary` excludes archived accounts but includes archived subaccounts
(totals, `as_of`, updates feed).

## Desired Behavior
`recompute_account_cached_total_usd` and `api_analytics_summary` (breakdown, `as_of`, updates) skip
archived subaccounts; caches are rebuilt once.

## Scope
One migration; rule documented in `docs/product/capabilities.md`.

## Out Of Scope
Removing the unused `cached_total_usd` cache.

## Acceptance Criteria
- [x] Live total, cached total and analytics total agree with an archived subaccount present.

## Verification
`qa/run.sh qa/api/subaccounts_balance.test.ts qa/api/history_analytics.test.ts`

## Documentation Updates
`docs/product/capabilities.md`, `docs/qa/findings.md`.

## Rollout Notes
`supabase db push` (rebuilds caches).
