# SPEC-0019: Analytics Non-Positive Base Rate

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-024: `api_analytics_summary` never divides by a base rate of 0 or below.

## Current Behavior
The base asset USD price is used as a divisor; a stored rate of `0` would raise `division by zero`
(500). `rates_sync` skips such rates today, so this is defensive.

## Desired Behavior
A non-positive base price is treated like a missing rate (`null` values), matching
`api_list_accounts`.

## Scope
One migration recreating `api_analytics_summary`.

## Acceptance Criteria
- [x] Analytics QA tests pass; the function treats `<= 0` as missing.

## Verification
`qa/run.sh qa/api/history_analytics.test.ts`

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
`supabase db push`.
