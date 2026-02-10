# Asset Tuner — API Assumptions

**Last updated:** 2026-02-10

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
- Persist numeric values in Postgres as `numeric`.
- In Flutter, use `decimal` for arithmetic; avoid `double` for amounts/rates.

## Security & RLS assumptions
- All user-owned rows include `user_id uuid not null default auth.uid()`.
- RLS policies:
  - `select/insert/update/delete` where `user_id = auth.uid()`.
- Catalog/rates tables are read-only for clients (no user_id; public read policies).

## Proposed domain objects (tables) — MVP
Names may change, but the responsibilities should not.

### User-owned
- `profiles` (1:1 with auth user, base currency, plan/entitlements)
- `accounts` (user containers, archived flag)
- `account_assets` (account ↔ asset many-to-many with ordering)
- `balance_entries` (snapshot + delta history per account_asset; immutable rows)

### Public/read-only
- `assets` (fiat + crypto catalog)
- `asset_rates_usd` (latest `usd_price` per asset + timestamp; server-written)

## Edge Functions (suggested endpoints)
- `POST /update_balance`
  - Input: `account_asset_id`, `entry_date`, `snapshot_amount` OR `delta_amount`
  - Behavior: on snapshot, compute implied delta vs previous snapshot and persist consistent history
- `DELETE /account`
  - Input: `account_id`
  - Behavior: cascade delete account + account_assets + balance_entries (authorized user only)
- `POST /rates_sync` (cron only)
  - Fetch providers and upsert into `asset_rates_usd`

## Deletion semantics
- User-initiated deletion is supported in MVP:
  - Account deletion removes dependent data (server-side cascade).
  - Soft-delete/archiving remains available separately for “hide from totals”.

