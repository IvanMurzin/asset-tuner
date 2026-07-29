# SPEC-0005: Document Supabase Operator Access

- **Type:** docs
- **Status:** Resolved
- **Priority:** P1
- **Owner:** codex
- **Created:** 2026-07-29
- **Resolved:** 2026-07-29

## Goal
Document the local, secret-safe procedure available to an agent for inspecting and, when explicitly requested, operating the hosted Supabase database.

## User Or Product Impact
Future sessions can accurately inspect the database, scheduler, rate freshness, and RevenueCat ledger without rediscovering connection details or exposing secrets.

## Current Behavior
`backend/.env` contains the hosted project connection configuration, and `backend/scripts/setup_rates_sync_cron.sh` uses it with `psql`; the operational documentation only lists runtime secrets and deploy commands.

## Desired Behavior
`docs/tech/operations.md` explains the available database access, secret-handling rules, safe connection command, and the authoritative checks for the rates scheduler.

## Scope
- Add a concise Supabase operator-access section to the operations documentation.
- Record how to distinguish cron enqueue success from a completed rates sync.

## Out Of Scope
- Changing the database schema, secrets, cron configuration, or Edge Function implementation.
- Recording any secret or personally identifying data in documentation.

## Constraints
- Keep documentation in English.
- Do not expose values from `backend/.env`.
- Preserve the existing Supabase and scheduler architecture.

## Implementation Notes
- Name `backend/.env` and `SUPABASE_DB_URL` as the canonical hosted database connection source.
- Use `psql` with an environment-variable connection string, never an inline credential.
- Identify `cron.job`, `cron.job_run_details`, `net._http_response`, and `asset_rates_usd` as scheduler/rate diagnostics.
- State that `pg_cron` success means a `pg_net` request was enqueued, while recent complete coverage and `asset_rates_usd.as_of` prove the sync completed.

## Acceptance Criteria
- [ ] A future agent can locate the connection configuration and run a read-only database check without exposing a secret.
- [ ] The documentation identifies the data sources for cron, HTTP, rates, and subscription diagnostics.
- [ ] The documentation does not contain credential values or customer data.

## Verification
- `git diff --check`
- Manual review that no value from `backend/.env` appears in tracked documentation.

## Documentation Updates
- `docs/tech/operations.md`

## Rollout Notes
None.
