# Asset Tuner — Integrations

**Last updated:** 2026-04-21

## Supabase
### Auth
- Email OTP
- OAuth: Google + Apple

### Database
- Postgres as system of record
- RLS enforced on all user-owned tables

### Edge Functions (preferred)
Used for:
- write workflows that must be atomic/validated server-side (e.g., snapshot → implied delta),
- privileged operations (e.g., cascade deletes, entitlements enforcement),
- scheduled jobs (rates sync).

## Rates providers (server-side only)
### OpenExchangeRates (FX)
- Pulled hourly by a scheduled job
- Stored in provider cache (`fx_rates_usd`) and projected to client-facing rates

### CoinGecko (crypto USD)
- Price endpoint pulled hourly by `rates_sync` (`/simple/price`)
- Metadata endpoints pulled weekly by `coingecko_refresh_metadata` (`/coins/list`, `/coins/markets`)
- Uses API key secret `COINGECKO_API_KEY` (legacy alias: `COINGEKO_API_KEY`)
- Stored in provider caches (`cg_coins_cache`, `cg_top_coins`, `crypto_rates_usd`) and projected to client-facing rates

## Monetization
### RevenueCat (subscriptions)
- Client SDK: `purchases_flutter` + `purchases_ui_flutter`
- Android: Google Play subscriptions (monthly + annual base plans)
- Entitlements source of truth: RevenueCat + backend sync
- Client flow:
  - load offerings (`Purchases.getOfferings`)
  - purchase / restore (`Purchases.purchase`, `Purchases.restorePurchases`)
  - manage subscription (`RevenueCatUI.presentCustomerCenter`)
- Backend flow:
  - `POST /api/revenuecat/refresh` reads subscriber state from RevenueCat API and applies plan via RPC
  - `revenuecat_webhook` receives async events and applies idempotent updates

## Observability (MVP)
- Client: structured app logging via `client/lib/core/logger` (log important app + API events)
- Crash reporting/analytics: **not in MVP** (planned next iteration)
