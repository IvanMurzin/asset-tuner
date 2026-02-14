# FTR-007: Server-cached rates (hourly) and rates timestamp

## Summary
Fetch fiat FX and crypto USD prices hourly via a Supabase scheduled job and store them in the DB as USD-pivot `usdPrice`, exposed to clients as read-only rates with a visible “last updated” timestamp.

The implementation uses a two-layer backend model:
- provider-layer caches (`fx_rates_usd`, `crypto_rates_usd`, CoinGecko metadata tables),
- client-facing projection (`asset_rates_usd`) for compatibility with existing client reads.

Source references:
- Product: `docs/prd/prd.md` (rates sources + hourly refresh), `docs/prd/requirements.md` (FR-060..FR-064, FR-011)
- Tech: `docs/tech/stack.md`, `docs/tech/integrations.md`, `docs/tech/api_assumptions.md` (`asset_rates_usd`, `POST /rates_sync`)

## User story
As a user, I want my totals to be converted using up-to-date rates, so that the global total is trustworthy and consistent across devices.

## Scope / Out of scope
Scope:
- Backend scheduled job runs at least hourly to:
  - fetch FX from OpenExchangeRates,
  - fetch crypto USD prices from CoinGecko (`/simple/price`, no hourly `/coins/list`),
  - upsert provider-layer rates and project latest `usd_price` per visible asset.
- Backend metadata scheduled job runs weekly to refresh CoinGecko caches (`coins/list`, `coins/markets`) and keep crypto mapping/ranking stable.
- Persist rates timestamp (`as_of`) for display and debugging.
- Client reads rates from Supabase DB only (no direct provider calls).

Out of scope:
- Intraday/minute-level refresh.
- User-triggered provider calls from client.
- Manual rate overrides (explicit non-goal; see `docs/prd/non_goals.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the scheduled job is configured, when one hour elapses, then a rates sync run is executed and updates `asset_rates_usd` rows (upsert).
- Given a rates sync run fails due to provider errors, when the job completes, then:
  - the previous last-known rates remain available to clients,
  - failure is logged server-side (implementation detail) and does not delete existing rates (see NFR-004 in `docs/prd/requirements.md`).
- Given the weekly metadata refresh runs, when it completes successfully, then:
  - `cg_coins_cache` and `cg_top_coins` are updated,
  - hourly sync can resolve crypto prices without calling `/coins/list`.
- Given the client loads rates, when it queries the DB, then it receives the latest `usd_price` per asset and the corresponding `as_of` timestamp.
- Given the Main screen is shown, when rates are available, then the UI displays “Rates updated at <timestamp>” using locale-aware formatting (see FTR-002).

## UX references (which screens it touches; placeholders ok)
- Screen: Main (shows “rates updated at” timestamp)
- Screen: Settings/About (optional diagnostics)

## States (loading/empty/error/success)
- Loading: fetching latest rates.
- Empty: no rates available (fresh install or prolonged outage) → totals cannot be computed; show a retryable state (handled in FTR-008).
- Error: network/unauthorized/unknown while reading rates → show retry.
- Success: rates loaded with timestamp.

## Client caching / refresh policy (MVP)
Rates update server-side hourly, but the client may need to read them from multiple screens. To avoid expensive repeated reads:
- Keep the latest rates snapshot in a shared in-memory cache (app-wide singleton).
- Persist the last-known snapshot locally for offline/poor-network starts.
- Refresh from Supabase **no more than once per minute** (soft TTL), and reuse the cached snapshot for all conversions.
- If a refresh fails, keep using the last-known snapshot (and show its `as_of` timestamp).

## Data needs (entities + fields)
- Provider-layer (server-managed):
  - `fx_rates_usd { code, usd_price, as_of, source }`
  - `crypto_rates_usd { coingecko_id, usd_price, as_of, source }`
  - `cg_coins_cache { coingecko_id, symbol, symbol_upper, name, updated_at }`
  - `cg_top_coins { coingecko_id, symbol_upper, name, rank, market_cap, updated_at }`
- Read-only `asset_rates_usd`
  - `asset_id: uuid`
  - `usd_price: text` (decimal string)
  - `as_of: timestamptz`
  - Optional: `provider: text`, `source_ref: text`
- Edge Function:
  - `POST /rates_sync` (cron-only; not callable by clients)
  - `POST /coingecko_refresh_metadata` (weekly cron-only)

## Analytics (events, optional)
Local logging only (no third-party in MVP per `docs/tech/integrations.md`):
- `rates_loaded { as_of_age_seconds }`
- `rates_missing {}`

## Open questions (if any)
- Historical rates:
  - **MVP decision:** store **latest only** (one `asset_rates_usd` row per asset) with `as_of` timestamp.
  - Time series rates can be added post-MVP if needed for reporting.
