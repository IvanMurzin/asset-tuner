# FTR-007: Server-cached rates (hourly) and rates timestamp

## Summary
Fetch fiat FX and crypto USD prices hourly via a Supabase scheduled job and store them in the DB as USD-pivot `usdPrice`, exposed to clients as read-only rates with a visible “last updated” timestamp.

Source references:
- Product: `docs/prd/prd.md` (rates sources + hourly refresh), `docs/prd/requirements.md` (FR-060..FR-064, FR-011)
- Tech: `docs/tech/stack.md`, `docs/tech/integrations.md`, `docs/tech/api_assumptions.md` (`asset_rates_usd`, `POST /rates_sync`)

## User story
As a user, I want my totals to be converted using up-to-date rates, so that the global total is trustworthy and consistent across devices.

## Scope / Out of scope
Scope:
- Backend scheduled job runs at least hourly to:
  - fetch FX from OpenExchangeRates,
  - fetch crypto USD prices from CoinGecko,
  - upsert latest `usd_price` per supported asset.
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
- Given the client loads rates, when it queries the DB, then it receives the latest `usd_price` per asset and the corresponding `as_of` timestamp.
- Given the Overview is shown, when rates are available, then the UI displays “Rates updated at <timestamp>” using locale-aware formatting (see FTR-002).

## UX references (which screens it touches; placeholders ok)
- Screen: Overview (shows “rates updated at” timestamp)
- Screen: Settings/About (optional diagnostics)

## States (loading/empty/error/success)
- Loading: fetching latest rates.
- Empty: no rates available (fresh install or prolonged outage) → totals must show missing-rate behavior (handled in FTR-008).
- Error: network/unauthorized/unknown while reading rates → show retry.
- Success: rates loaded with timestamp.

## Data needs (entities + fields)
- Read-only `asset_rates_usd`
  - `asset_id: uuid`
  - `usd_price: numeric`
  - `as_of: timestamptz`
  - Optional: `provider: text`, `source_ref: text`
- Edge Function:
  - `POST /rates_sync` (cron-only; not callable by clients)

## Analytics (events, optional)
Local logging only (no third-party in MVP per `docs/tech/integrations.md`):
- `rates_loaded { as_of_age_seconds }`
- `rates_missing {}`

## Open questions (if any)
- Historical rates:
  - **MVP decision:** store **latest only** (one `asset_rates_usd` row per asset) with `as_of` timestamp.
  - Time series rates can be added post-MVP if needed for reporting.
