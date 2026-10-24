# SPEC-0035: Plan Limit Lock And Support Cascade

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-017 and QA-041: parallel requests cannot exceed free-plan limits, and deleting an account
also deletes the user's support messages.

## Current Behavior
- `api_create_account`, `api_create_subaccount` and `api_create_support_message` count rows and
  then insert without a lock; 20 parallel subaccount creates reached 16 of 15.
- `support_messages.user_id` is `on delete set null`, so name, email and text outlive the account.

## Desired Behavior
- Each of the three functions takes
  `pg_advisory_xact_lock(hashtext('asset_tuner.user_limits'), hashtext(p_user_id::text))` first.
  Bodies are otherwise the production definitions.
- `support_messages.user_id` is `on delete cascade`.

## Scope
Migrations `20261025120000_serialize_plan_limit_checks.sql`,
`20261025120100_support_messages_cascade_on_user_delete.sql`; QA API tests; data contract.

## Out Of Scope
Messages already orphaned by earlier deletions.

## Acceptance Criteria
- [x] New API test: 20 parallel subaccount creates stay within 15.
- [x] Delete test: the user's support message is gone after deletion (failed before the deploy).
- [x] Full `qa/run.sh`: 38/38; health §1, §2 and §10 return 0 rows.

## Verification
`qa/run.sh`; `psql "$SUPABASE_DB_URL" -X -f qa/sql/health.sql`.

## Documentation Updates
`docs/contracts/data-contract.md`, `docs/qa/findings.md`.

## Rollout Notes
Applied to prod with `supabase db push` on 2026-10-25.
