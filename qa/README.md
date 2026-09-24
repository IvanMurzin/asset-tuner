# QA Regression Suite

Code-level regression checks for the Asset Tuner backend. They run against the **hosted** Supabase
project, which dev and prod share. UI and device checks live in `docs/qa/`.

## Contents
- `run.sh`: entry point. Loads secrets into the process environment only and runs Deno tests.
  `run.sh tool <script>` runs a helper script with the same env.
- `lib/`: env loading, the API client, disposable QA users, and fixtures.
- `api/*.test.ts`: API regression tests, grouped by area (catalog: `docs/qa/cases/code.md`).
- `sql/health.sql`: read-only production health checks (grants, rates cron, freshness,
  subscriptions, leftovers).
- `emulator/ui.py`: `adb` driver for the Android emulator (dump the semantics tree, tap by label,
  type, screenshot, toggle the network, read logs).
- `emulator/user_api.ts`: acts as an app user with the publishable key: seed accounts,
  subaccounts and history; revoke sessions.
- `tools/delete_users.ts`: hard-deletes QA users by id (`run.sh tool qa/tools/delete_users.ts <ids>`).

The full regression procedure is `docs/qa/regression-runbook.md`, or run `/regress`.

## Run
From the repository root:

```bash
qa/run.sh
qa/run.sh qa/api/accounts.test.ts
```

Requirements:
- `deno`, `python3`, `psql`;
- the `supabase` CLI, logged in with access to the project;
- `backend/.env`, which provides `SUPABASE_PROJECT_REF` and `REVENUECAT_WEBHOOK_SECRET`;
- `.config.prod.json`, which provides the Supabase URL and publishable key.

`run.sh` gets the project secret key with `supabase projects api-keys --reveal`. It never prints
the key.

Health checks:

```bash
set -a; source backend/.env; set +a
psql "$SUPABASE_DB_URL" -X -f qa/sql/health.sql
```

## Safety Rules
- Every test that writes data runs as a disposable user with an email like
  `qa+<label>-<timestamp>-<id>@asset-tuner.test`. `withUsers` always hard-deletes that user in
  `finally`, along with their support messages and ledger rows.
- `deleteQaUser` refuses to delete any user whose email is not a QA address.
- Test data never touches real users. Plan switches (`setPlan`) change only the QA user's
  profile.
- Webhook tests send synthetic `TEST` events for QA users. The webhook asks RevenueCat about
  that app user id, so the RevenueCat dashboard may show short-lived anonymous QA customers.
- `rates_sync` is only called with a wrong secret. The suite never triggers a real sync.
- After a run, section 10 of `health.sql` must show no leftover `qa+%` users.

## Conventions
- Tests assert the **intended** behavior. A failing test is either a regression or a known
  finding recorded in `docs/qa/findings.md`, and the failure message points to it.
- Keep the suite finite: 1–3 cases per behavior, happy path first, then the limits and
  validations that protect data and billing.
