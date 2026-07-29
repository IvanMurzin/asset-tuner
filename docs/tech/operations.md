# Operations

## Configuration Files
Runtime config is passed with Flutter `--dart-define-from-file`:

- `.config.dev.json`
- `.config.prod.json`

These files are gitignored. Templates live at the repository root as `*.example` files when present.

## Client Run Commands
Run from `client/`:

```bash
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build appbundle --flavor prod --release --dart-define-from-file=../.config.prod.json
```

## Backend Secrets
Production backend requires:

- `OPENEXCHANGERATES_APP_ID`
- `SCHEDULER_SECRET`
- `REVENUECAT_WEBHOOK_SECRET`
- `REVENUECAT_API_KEY`
- `REVENUECAT_PRO_ENTITLEMENTS` — entitlement identifier(s) that grant the pro plan, copied from
  RevenueCat: Product catalog -> Entitlements -> **Identifier** (CSV for several). Matched
  case-insensitively. There is no default: a wrong or missing value silently resolves every
  paying subscriber to `free`.

Optional:

- `COINGECKO_API_KEY`

Supabase provides platform secrets such as `SUPABASE_URL` and `SUPABASE_SECRET_KEYS`
automatically in hosted Edge Functions. Do not set or deploy those through project `.env` files.

## Hosted Supabase Database Access

The repository's operator configuration is in the gitignored `backend/.env`. It contains
`SUPABASE_PROJECT_REF`, `SUPABASE_DB_URL`, and the secrets needed by the deployed functions.
Never print, commit, or place values from that file in a command, documentation, or issue.

For a hosted-database inspection, load the file into the process environment and pass the
connection string by variable:

```bash
set -a
source backend/.env
set +a
psql "$SUPABASE_DB_URL"
```

Use read-only SQL for diagnostics. Write, DDL, secret, or data-deletion operations require an
explicit request and a target-specific review. If `SUPABASE_DB_URL` is absent, the scheduler
setup script documents the supported pooler fallback using `SUPABASE_DB_PASSWORD` and
`backend/supabase/.temp/pooler-url`.

The Supabase CLI can also use the linked project, but it writes telemetry under the user home
directory; in a restricted agent sandbox it may need an approved elevated invocation. `psql`
with the configured URL is the preferred database diagnostic path.

For rate-scheduler health, inspect all of the following:

- `cron.job` for the active hourly `asset_tuner_rates_sync_hourly` schedule;
- `cron.job_run_details` for whether `pg_cron` enqueued each `pg_net` call;
- `net._http_response` for the recent HTTP status or timeout; this unlogged table is a short
  retention aid, not historical monitoring;
- `assets` joined with `asset_rates_usd` for active fiat/crypto coverage and the newest
  `asset_rates_usd.as_of` timestamp.

`cron.job_run_details.status = 'succeeded'` confirms that the asynchronous HTTP request was
queued, not that the Edge Function returned 2xx. A completed rate sync is proven by current
coverage for active fiat and crypto assets plus a recent shared `asset_rates_usd.as_of`; consult
Edge Function logs when the HTTP response or freshness check is unhealthy.

For subscription diagnostics, inspect `profiles` (`plan`, unique non-empty
`revenuecat_app_user_id`) and `webhook_events` (source, event type, duplicate
`(source, external_id)` pairs, and recent receipt time). Do not export raw webhook payloads,
user IDs, or customer records unless the request explicitly requires them.

## Backend Deploy
Run from repository root:

```bash
./backend/scripts/deploy_supabase.sh
```

The script links the project, pushes migrations, applies secrets, deploys functions, and can trigger an initial rates sync depending on environment configuration.

## Scheduled Jobs
Configure an hourly scheduler for `rates_sync` and pass:

```text
x-scheduler-secret: <SCHEDULER_SECRET>
```

Use `backend/scripts/setup_rates_sync_cron.sh` when available.

## RevenueCat
Set webhook URL:

```text
https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook
```

Set header:

```text
Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>
```

## Firebase
Firebase is configured for the production flavor.

- Android prod config: `client/android/app/src/prod/google-services.json`
- iOS prod config: `client/ios/Runner/GoogleService-Info.plist`
- Firebase project: `assettuner-8dc26`

Firebase initialization is gated by `AppConfig.firebaseEnabled`.
Analytics is active only when Firebase is enabled, analytics is enabled, and the app is running in release mode.

## Release Signing
- Dev Android release uses the debug keystore.
- Prod Android release requires `client/android/key.properties`.
- iOS flavor scheme setup is documented in `docs/flavors-and-accounts.md`.
