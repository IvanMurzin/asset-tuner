# Asset Tuner — API Assumptions — v2 (breaking)

**Last updated:** 2026-02-14

## Breaking change note
This document is updated for **MVP v2** (rewrite):
- “Assets inside accounts” are modeled as **unlimited named subaccounts** (`subaccounts`).
- Balance updates are **snapshot-only** (no delta input).

## API style
- **Reads:** Supabase PostgREST (direct table reads) where safe under RLS.
- **Writes:** Supabase **Edge Functions** preferred (server-side validation, atomic workflows, cascade operations).

## Realtime
- No Supabase Realtime subscriptions in MVP.
- Client refreshes on app resume + manual pull-to-refresh.

## Pagination
- History lists are paginated (default page size: 50).
- Stable sorting:
  - balance history: `entry_date desc, created_at desc`

## Error model (client-facing)
Normalize backend errors into `Failure { code, message }` with codes:
- `network`
- `unauthorized`
- `forbidden`
- `not_found`
- `validation`
- `conflict`
- `rate_limited`
- `unknown`

## Money / decimals
- Persist money/rates in Postgres as decimal strings in `text` columns.
- In Flutter, parse those strings directly to `Decimal`; do not use `double` for amounts/rates.

## Security & RLS assumptions
- All user-owned rows include `user_id uuid not null default auth.uid()`.
- RLS policies:
  - `select/insert/update/delete` where `user_id = auth.uid()`.
- Catalog/rates tables are read-only for clients (no user_id).
- `assets` and `asset_rates_usd` use plan-aware read policies:
  - `free` users are limited by configured rank caps (`plan_limits`),
  - `paid` defaults to top-100 per kind (`allow_all=false` by default),
  - `anon` is treated as `free`.

## Proposed domain objects (tables) — MVP
Names may change, but the responsibilities should not.

### User-owned
- `profiles` (1:1 with auth user, base currency, plan/entitlements)
- `accounts` (user containers, archived flag)
- `subaccounts` (account ↔ asset with a user-defined name; unlimited per account)
- `balance_entries` (snapshot-only history per subaccount; immutable rows)

### Public/read-only
- `assets` (fiat + crypto catalog)
- `asset_rates_usd` (latest `usd_price` per asset + timestamp; server-written)
- Provider-layer caches:
  - `fx_rates_usd`, `crypto_rates_usd`
  - `cg_coins_cache`, `cg_top_coins`

## Edge Functions (suggested endpoints)
- `POST /create_subaccount`
  - Input: `account_id`, `name`, `asset_id`, `snapshot_amount`, `entry_date`
  - Behavior: create `subaccounts` row + initial snapshot in a single atomic operation
- `POST /update_subaccount_balance`
  - Input: `subaccount_id`, `entry_date`, `snapshot_amount`
  - Behavior: store a new snapshot and compute/store `diff_amount` vs previous snapshot
- `POST /rename_subaccount`
  - Input: `subaccount_id`, `name`
- `DELETE /subaccount`
  - Input: `subaccount_id`
- `DELETE /account`
  - Input: `account_id`
  - Behavior: cascade delete account + subaccounts + balance_entries (authorized user only)
- `POST /rates_sync` (cron only)
  - Fetch provider rates, upsert provider-layer tables, then project to `asset_rates_usd`
- `POST /coingecko_refresh_metadata` (cron only, weekly)
  - Refresh CoinGecko metadata caches and run idempotent assets autofill

## Deletion semantics
- User-initiated deletion is supported in MVP:
  - Account deletion removes dependent data (server-side cascade).
  - Soft-delete/archiving remains available separately for “hide from totals”.
