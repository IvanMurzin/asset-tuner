# Manual requirements (Supabase Dashboard / External setup)

This file lists steps that cannot be fully automated via code/CLI and must be done manually in Supabase Dashboard (or provider consoles).

## 1) Create Supabase projects
- Create 2 projects: `dev` + `prod` (no staging per `docs/tech/stack.md`).
- Copy project refs (needed for `./scripts/supabase_link.sh <project-ref>`).

## 2) Auth configuration (Dashboard)
The Flutter client uses:
- Email OTP sign-in (`signInWithOtp`)
- Email+password sign-up + OTP verification (`signUp` + `verifyOTP(type=signup)`)
- OAuth sign-in: Google + Apple (optional but referenced in docs)

Dashboard → **Authentication**:
- Enable Email provider (OTP / magic link + email confirmations as needed for your flow).
- Configure SMTP (recommended for prod deliverability).

Dashboard → **Authentication → URL Configuration**:
- Add the app’s redirect URLs (deep links) used by `supabase_flutter` for OAuth.
  - If you don’t know them yet, do this after mobile bundle ids / schemes are finalized.

Dashboard → **Authentication → Providers**:
- Configure **Google** OAuth (Client ID/secret).
- Configure **Apple** OAuth (Service ID / Key ID / Team ID / private key).

## 3) Scheduled jobs (rates + metadata)
Both jobs are deployed with `verify_jwt = false` and are protected by `RATES_SYNC_SECRET`.

Dashboard → **Edge Functions → rates_sync → Scheduled triggers**:
- Schedule: hourly
- Method: `POST`
- Body/payload (JSON):
  - `{ "secret": "<RATES_SYNC_SECRET>" }`

Dashboard → **Edge Functions → coingecko_refresh_metadata → Scheduled triggers**:
- Schedule: weekly
- Method: `POST`
- Body/payload (JSON):
  - `{ "secret": "<RATES_SYNC_SECRET>" }`

If the Scheduler UI does not support a body, use headers (if supported):
- Header: `x-rates-sync-secret: <RATES_SYNC_SECRET>`

## 4) External provider keys
Create/get credentials and set them via `./scripts/supabase_set_secrets.sh`:
- `OPENEXCHANGE_APP_ID` (OpenExchangeRates)
- `COINGECKO_API_KEY` (CoinGecko)
- `RATES_SYNC_SECRET` (random secret; protect `rates_sync`)

Legacy compatibility is kept for `COINGEKO_API_KEY` (typo key), but use `COINGECKO_API_KEY` as canonical.

Optional tuning vars:
- `RATES_SYNC_MAX_CRYPTO` (default 100) for top crypto scope.
- `RATES_SYNC_MAX_FIAT` (default 100) for top fiat scope (priority + fallback fill).
- `COINGECKO_BASE_URL` (optional override; for Pro keys can be set to `https://pro-api.coingecko.com/api/v3`).

## 4.1) Env files (dev/prod) and where to get values
Fill these files locally (do not commit):
- `backend/supabase/.env.dev`
- `backend/supabase/.env.prod`

Sources for each variable:
- `SUPABASE_PROJECT_REF`
  - Dashboard → Project Settings → General → **Reference ID**
- `SUPABASE_URL`
  - Dashboard → Project Settings → API → **Project URL**
- `SUPABASE_DB_URL`
  - Dashboard → Project Settings → Database → **Connection string**
  - Use a `postgresql://...` URI that works with `psql`.
- `OPENEXCHANGE_APP_ID`
  - OpenExchangeRates account → App ID
- `COINGECKO_API_KEY`
  - CoinGecko account → API key
- `COINGEKO_API_KEY`
  - Legacy alias (optional fallback; prefer `COINGECKO_API_KEY`)
- `COINGECKO_BASE_URL`
  - Optional CoinGecko API root override (useful for Pro key routing)
- `RATES_SYNC_SECRET`
  - Generate yourself (random string), then set:
    - secrets via `./scripts/supabase_set_secrets.sh <env>`
    - scheduler payload/header (see section 3)
- `RATES_SYNC_MAX_CRYPTO`
  - Optional tuning (default 100)
- `RATES_SYNC_MAX_FIAT`
  - Optional tuning for fiat autofill (default 100, priority + fallback)
- `UPDATE_PLAN_ENABLED`, `UPDATE_PLAN_ALLOWLIST_EMAILS`
  - Dev/testing only (see section 5)

## 5) update_plan (dev/testing only)
`update_plan` exists to support the current client “upgrade” stub (see docs/features).

Recommended:
- **prod**: keep `UPDATE_PLAN_ENABLED=false`
- **dev**: set `UPDATE_PLAN_ENABLED=true` and optionally restrict by email:
  - `UPDATE_PLAN_ALLOWLIST_EMAILS=you@example.com`

## 6) (Optional) Asset catalog scope
The schema is ready for a large `assets` catalog, but this repo only seeds a minimal set in `backend/supabase/seed.sql`.

If you want a larger catalog in prod:
- Replace `backend/supabase/seed.sql` with a generated full catalog (fiat + crypto),
- Run `./scripts/supabase_seed_remote.sh` (requires `psql` + `SUPABASE_DB_URL`).
