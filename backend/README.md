# Asset Tuner Supabase Backend

The backend is a clean Supabase API layer:

- The Flutter client does not call product tables through direct PostgREST.
- The app API is exposed through Edge Functions.
- API handlers call SQL RPC functions with an elevated Supabase Secret key client.
- Monetary values use `*_atomic TEXT` plus `*_decimals SMALLINT`.
- RLS is enabled on product tables; direct `anon` and `authenticated` table access is denied.

## Contents
- `supabase/migrations/` - schema, functions, RLS, grants, and later fixes.
- `supabase/seed.sql` - plan limits and initial fiat/crypto catalog seed data.
- `supabase/functions/api` - authenticated app API.
- `supabase/functions/rates_sync` - scheduler/server rates sync.
- `supabase/functions/revenuecat_webhook` - RevenueCat webhook ingestion.
- `supabase/functions/_shared` - shared auth, DB, validation, money, response, and env helpers.

## API Model
The authenticated app calls:

```text
https://<project-ref>.supabase.co/functions/v1/api/<route>
```

Documented routes live in `docs/contracts/api-surface.md`.

Important route groups:
- `/me`
- `/profile/update`
- `/accounts/*`
- `/subaccounts/*`
- `/assets/list`
- `/rates/usd`
- `/analytics/summary`
- `/contact_developer`
- `/revenuecat/refresh`
- `/delete_my_account`

## Required Production Secrets
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

## Deploy
Recommended script:

```bash
./backend/scripts/deploy_supabase.sh
```

Manual outline:

```bash
cd backend
supabase link --project-ref <project-ref>
supabase db push
supabase secrets set OPENEXCHANGERATES_APP_ID=... SCHEDULER_SECRET=...
supabase functions deploy api
supabase functions deploy rates_sync --no-verify-jwt
supabase functions deploy revenuecat_webhook --no-verify-jwt
```

## Post-Deploy Setup
1. Configure hourly scheduler for `rates_sync`.
2. Pass `x-scheduler-secret: <SCHEDULER_SECRET>` to scheduler calls.
3. Configure RevenueCat webhook URL:
   `https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook`
4. Configure RevenueCat webhook authorization header:
   `Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>`
5. Enable required Supabase Auth providers for the client.

## Smoke Tests
1. Free user creating a 6th account returns `LIMIT_ACCOUNTS_REACHED`.
2. Free user creating a locked asset subaccount returns `ASSET_NOT_ALLOWED_FOR_PLAN`.
3. Pro user can exceed free limits.
4. `rates_sync` updates `asset_rates_usd.as_of` and recomputes account cached totals.
5. `delete_my_account` deletes the auth user and cascades user data.
6. `revenuecat_webhook` moves `profiles.plan` between `free` and `pro`.

## Ranking
Top fiat assets are defined in `supabase/functions/_shared/fiat_top100.ts` and seed data.
Top crypto assets are seeded from `supabase/seeds/crypto_top100_snapshot.tsv`.
`rates_sync` refreshes provider metadata, rates, and ranks where supported.
