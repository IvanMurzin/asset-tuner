# Asset Tuner — Data Contract (Supabase)

This document is the concrete, single-source contract for persisted entities in Supabase (Auth + Postgres + Storage).

If any code, migrations, or edge functions disagree with this document, treat it as a bug.

**Last updated:** 2026-02-11

## Conventions
- **IDs:** `uuid` (generated server-side).
- **Timestamps:** `timestamptz` in UTC.
- **Money/rates:** `numeric` (never `float`).
- **User ownership:** all user-owned rows include `user_id uuid not null default auth.uid()`.
- **RLS:** user-owned tables restrict `select/insert/update/delete` to `user_id = auth.uid()`.
- **Catalog:** read-only for clients (public read policy; no user_id).

## Entities (tables)

### `profiles` (user-owned, 1:1 with auth user)
Represents user preferences and entitlement state required by the client.

Fields:
- `user_id uuid` (PK, references `auth.users.id`)
- `base_currency text not null`
- `plan text not null` in `{ "free", "paid" }`
- `entitlements jsonb not null`
  - shape:
    - `max_accounts int`
    - `max_positions int`
    - `any_base_currency bool`
    - `allowed_base_currency_codes text[]` (used when `any_base_currency = false`)
    - `expires_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `base_currency` must be a supported fiat asset code from `assets` where `kind = "fiat"`.
- `entitlements.allowed_base_currency_codes` must be uppercase ISO codes.

Relations:
- `profiles.user_id` 1—* `accounts.user_id`

---

### `accounts` (user-owned)
Top-level containers (bank, cash, wallet).

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `name text not null` (trimmed, non-empty)
- `type text not null` in `{ "bank", "crypto_wallet", "cash", "other" }`
- `archived bool not null default false`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `(user_id, name)` uniqueness is optional; not enforced in MVP.

Relations:
- `accounts.id` 1—* `account_assets.account_id`

---

### `assets` (public/read-only)
Catalog of fiat + crypto assets.

Fields:
- `id uuid` (PK)
- `kind text not null` in `{ "fiat", "crypto" }`
- `code text not null` (uppercase; unique within kind)
- `name text not null`
- `decimals int null`

Constraints:
- `code` must be uppercase.

Relations:
- `assets.id` 1—* `account_assets.asset_id`
- `assets.id` 1—1 `asset_rates_usd.asset_id` (latest snapshot)

---

### `account_assets` (user-owned)
Many-to-many join of accounts and assets (an "asset position").

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `account_id uuid not null` (FK → `accounts.id`)
- `asset_id uuid not null` (FK → `assets.id`)
- `sort_order int null`
- `created_at timestamptz not null default now()`

Constraints:
- Unique: `(account_id, asset_id)`

Relations:
- `account_assets.id` 1—* `balance_entries.account_asset_id`

---

### `balance_entries` (user-owned, immutable)
History entries that determine balances for each position.

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `account_asset_id uuid not null` (FK → `account_assets.id`)
- `entry_date date not null`
- `entry_type text not null` in `{ "snapshot", "delta" }`
- `snapshot_amount numeric null`
- `delta_amount numeric null`
- `implied_delta_amount numeric null`
- `created_at timestamptz not null default now()`

Constraints:
- Exactly one of `snapshot_amount` or `delta_amount` is non-null.
- If `entry_type = "snapshot"` then `snapshot_amount` is non-null and `delta_amount` is null.
- If `entry_type = "delta"` then `delta_amount` is non-null and `snapshot_amount` is null.
- `entry_date` must not be in the far future (server enforces).

Indexing / ordering:
- Stable descending order for pagination: `entry_date desc, created_at desc`.

---

### `asset_rates_usd` (public/read-only for clients; server-written)
Latest known USD price per asset (a pivot for conversion).

Fields:
- `asset_id uuid` (PK, FK → `assets.id`)
- `usd_price numeric not null`
- `as_of timestamptz not null`

Constraints:
- `usd_price > 0`

## Storage (buckets)

### `asset_icons` (public read)
Optional bucket for asset icons.

Object key convention:
- `assets/{asset_id}.png`
- `assets/{asset_id}.svg`

The client must treat icons as optional and fall back to a generic glyph.

