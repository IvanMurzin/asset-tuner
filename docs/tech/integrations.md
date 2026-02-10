# Asset Tuner — Integrations

**Last updated:** 2026-02-10

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
- Stored in Supabase DB and served to clients from DB only

### CoinGecko (crypto USD)
- Pulled hourly by a scheduled job
- Stored in Supabase DB and served to clients from DB only

## Monetization (MVP)
- Subscription (monthly + annual)
- Implementation integration: **TBD** (ADR required before choosing)

## Observability (MVP)
- Client: structured app logging via `client/lib/core/logger` (log important app + API events)
- Crash reporting/analytics: **not in MVP** (planned next iteration)

