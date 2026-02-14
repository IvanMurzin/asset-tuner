# Asset Tuner — Integrations

**Last updated:** 2026-02-14

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

## Monetization (MVP)
- Subscription (monthly + annual)
- Implementation integration: **TBD** (ADR required before choosing)

## Observability (MVP)
- Client: structured app logging via `client/lib/core/logger` (log important app + API events)
- Crash reporting/analytics: **not in MVP** (planned next iteration)
