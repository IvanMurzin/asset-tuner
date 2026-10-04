# SPEC-0011: Canonical Atomic Amounts

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-016: an atomic amount has exactly one text form, so the unchanged-balance check (text
comparison) is correct.

## Current Behavior
`validate_amount_atomic` and the API `atomicStringSchema` accept `^-?\d+$`, so `0100` and `-0` are
stored as-is and `0100` after `100` counts as a change. All internal writers (`numeric::text`,
`BigInt.toString()`, client `MoneyAtomic`) already produce the canonical form; prod data is canonical.

## Desired Behavior
Canonical form `^(0|-?[1-9][0-9]*)$` is the contract at both boundaries: API schema (400) and
`validate_amount_atomic` (used by RPCs and the CHECK constraints of `balance_entries`,
`subaccounts`, `accounts`, `asset_rates_usd`).

## Scope
- Migration redefining `validate_amount_atomic`.
- `backend/supabase/functions/_shared/validation.ts` `atomicStringSchema`.

## Out Of Scope
`api_set_subaccount_balance` logic (text comparison becomes correct by the contract).

## Acceptance Criteria
- [x] `0100` / `-0` are rejected with 400; `0`, `100`, `-5` accepted.
- [x] `subaccounts_balance.test.ts` "numerically equal amounts" passes.

## Verification
`qa/run.sh qa/api/subaccounts_balance.test.ts`

## Documentation Updates
`docs/contracts/data-contract.md` (atomic amount format), `docs/qa/findings.md`.

## Rollout Notes
`supabase db push` and deploy the `api` function.
