# SPEC-0006: Revoke Public Execute On API RPCs

- **Type:** bug
- **Status:** Resolved
- **Priority:** P0
- **Owner:** claude
- **Created:** 2026-09-24
- **Resolved:** 2026-09-24

## Goal
Close QA-001: no `public` schema function is executable by `anon`/`authenticated`, and functions
re-created by future migrations stay closed by default.

## User Or Product Impact
Anyone with the publishable key (shipped in the APK) can currently create/edit accounts and
subaccounts for any user id through PostgREST. After the fix only Edge Functions (`service_role`)
can call these RPCs. No change for app users.

## Current Behavior
- Migrations `20260221120000`–`20260221120003` `drop` + `create` `api_create_subaccount`,
  `api_update_subaccount`, `api_update_account`, `api_create_account` without repeating the
  revoke/grant from `20260217200132`–`200157`; the new functions got Supabase default privileges.
- `qa/sql/health.sql` section 1 lists these four plus `handle_auth_user_created` and
  `handle_balance_entry_insert` as executable by `anon`/`authenticated`.

## Desired Behavior
- Section 1 of `qa/sql/health.sql` returns 0 rows.
- PostgREST `rpc/api_*` calls with the publishable key are denied.
- Functions created later in `public` by `postgres` do not get `EXECUTE` for
  `public`/`anon`/`authenticated` by default.

## Scope
- One new migration:
  - `revoke all ... from public, anon, authenticated` + `grant execute ... to service_role` for the
    four `api_*` signatures and the two `handle_*` trigger functions;
  - `alter default privileges for role postgres revoke execute on functions from public;`
  - `alter default privileges for role postgres in schema public revoke execute on functions from anon, authenticated;`
- Extend the RPC probe in `qa/api/billing_security.test.ts` with the two subaccount RPCs.
- Apply the migration to the hosted project.

## Out Of Scope
- Changing function bodies, Edge Functions, or the client.
- Other QA findings.

## Constraints
- The client never calls `.rpc()` directly; Edge Functions use the secret key (`service_role`).
- The global default for `PUBLIC` cannot be revoked with `IN SCHEMA`, hence two
  `alter default privileges` statements.

## Implementation Notes
Signatures:
- `api_create_account(uuid, text, text)`
- `api_update_account(uuid, uuid, text, text, boolean)`
- `api_create_subaccount(uuid, uuid, uuid, text, text, smallint)`
- `api_update_subaccount(uuid, uuid, text, boolean)`
- `handle_auth_user_created()`, `handle_balance_entry_insert()`

## Acceptance Criteria
- [x] `qa/sql/health.sql` section 1 returns 0 rows on the hosted project.
- [x] `billing_security.test.ts` RPC probe passes (all probes denied).
- [x] Account/subaccount create/update through the `api` Edge Function still work (API suite).
- [x] Default ACL in `pg_default_acl` no longer grants function `EXECUTE` to `anon`/`authenticated`/`PUBLIC` for `postgres`.

## Verification
- `psql "$SUPABASE_DB_URL" -X -f qa/sql/health.sql` (section 1)
- `deno test` for `qa/api/billing_security.test.ts`, `accounts.test.ts`, `subaccounts_balance.test.ts`

## Documentation Updates
- `docs/tech/backend-architecture.md`: RPC privilege rule.
- `docs/qa/findings.md`: mark QA-001 fixed and verified.

## Rollout Notes
Migration is applied to the single hosted project (dev = prod) with `supabase db push`.
