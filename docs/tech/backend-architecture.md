# Backend Architecture

The backend is a Supabase project under `backend/supabase`.

## Current Shape
- Supabase Auth owns users and JWT sessions.
- Postgres stores all product data.
- The Flutter client calls Supabase Edge Functions, not direct table PostgREST.
- The main authenticated API is one Edge Function: `backend/supabase/functions/api/index.ts`.
- API handlers call SQL RPC functions with a service role Supabase client.
- RLS is enabled on tables; direct table access by `anon` and `authenticated` is denied.
- Scheduled/server-only functions handle rates sync and RevenueCat webhooks.

## Edge Functions
| Function | JWT | Purpose |
|---|---:|---|
| `api` | yes | Authenticated app API under `/functions/v1/api/...`. |
| `rates_sync` | no | Scheduler-triggered rates and metadata refresh. |
| `revenuecat_webhook` | no | RevenueCat webhook ingestion and idempotent plan sync. |

## SQL RPC
The API function routes product reads/writes through SQL functions such as:

- `api_get_me`
- `api_profile_update_base_asset`
- `api_list_assets`
- `api_get_rates_usd`
- `api_list_accounts`
- `api_create_account`
- `api_update_account`
- `api_delete_account`
- `api_list_subaccounts`
- `api_create_subaccount`
- `api_update_subaccount`
- `api_delete_subaccount`
- `api_set_subaccount_balance`
- `api_subaccount_history`
- `api_analytics_summary`
- `api_create_support_message`
- `api_apply_revenuecat_event`

## Money Model
Money, balances, rates, and analytics values use atomic text fields plus decimal precision:

- `amount_atomic` + `amount_decimals`
- `current_amount_atomic` + `current_amount_decimals`
- `usd_price_atomic` + `usd_price_decimals`
- `value_atomic` + `value_decimals`

Do not introduce `double`-style storage for financial values.

## Rates
- Fiat rates come from OpenExchangeRates.
- Crypto prices come from CoinGecko.
- Latest client-facing USD prices live in `asset_rates_usd`.
- `rates_sync` updates rates and recomputes cached totals.

## Subscriptions
- RevenueCat SDK handles client purchase UI.
- `api/revenuecat/refresh` reads RevenueCat subscriber state.
- `revenuecat_webhook` applies asynchronous subscription changes.
- Backend plan state is stored in `profiles.plan`.

## Deployment
Primary deploy script:

```bash
cd backend
./scripts/deploy_supabase.sh
```

Operational details live in `docs/tech/operations.md`.
