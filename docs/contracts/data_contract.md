# Asset Tuner — Data Contract (Supabase) — v2 (breaking)

This document is the concrete, single-source contract for persisted entities in Supabase (Auth + Postgres + Storage).

If any code, migrations, or edge functions disagree with this document, treat it as a bug.

**Last updated:** 2026-02-12

## Versioning / breaking changes
This contract is **v2** and is intentionally **breaking** vs earlier MVP drafts:
- Replace the “one asset per account” model with **unlimited named subaccounts** inside an account.
  - Example: `TrustWallet` → `USDT (TRC20)`, `Bitcoin`.
- Balance tracking is **snapshot-only** for now (no delta input in UI).
- Analytics is based on snapshot updates (diff computed from consecutive snapshots).

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
    - `max_subaccounts int`
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
Top-level containers (bank, wallet, exchange, cash, other).

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `name text not null` (trimmed, non-empty)
- `type text not null` in `{ "bank", "wallet", "exchange", "cash", "other" }`
- `archived bool not null default false`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `(user_id, name)` uniqueness is optional; not enforced in MVP.

Relations:
- `accounts.id` 1—* `subaccounts.account_id`

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
- `assets.id` 1—* `subaccounts.asset_id`
- `assets.id` 1—1 `asset_rates_usd.asset_id` (latest snapshot)

---

### `subaccounts` (user-owned)
User-created “subaccounts” (a.k.a. “счета”) inside an account.

Notes:
- **Unlimited** subaccounts per account.
- A subaccount has a user-defined `name` that is **required** and **not derived** from currency.
- `asset_id` (currency/token) is **immutable** after creation.

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `account_id uuid not null` (FK → `accounts.id`)
- `asset_id uuid not null` (FK → `assets.id`)
- `name text not null` (trimmed, non-empty)
- `archived bool not null default false`
- `sort_order int null` (optional; UI ordering)
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- No uniqueness constraints in MVP v2 (user may create multiple subaccounts with same currency and/or same name).
- `name` must be non-empty after trimming (server validates).

Relations:
- `subaccounts.id` 1—* `balance_entries.subaccount_id`

---

### `balance_entries` (user-owned, immutable; snapshot-only)
Balance history entries for each subaccount.

Notes:
- v2 is **snapshot-only** input.
- Each new snapshot stores an optional computed diff vs the prior snapshot (server-computed).

Fields:
- `id uuid` (PK)
- `user_id uuid not null default auth.uid()` (FK → `profiles.user_id`)
- `subaccount_id uuid not null` (FK → `subaccounts.id`)
- `entry_date date not null`
- `snapshot_amount numeric not null`
- `diff_amount numeric null`
- `created_at timestamptz not null default now()`

Constraints:
- `entry_date` must not be in the far future (server enforces).

Indexing / ordering:
- Stable descending order for pagination: `entry_date desc, created_at desc`.
- For “previous snapshot” when computing diffs: `entry_date asc, created_at asc`.

---

### `asset_rates_usd` (public/read-only for clients; server-written)
Latest known USD price per asset (a pivot for conversion).

Fields:
- `asset_id uuid` (PK, FK → `assets.id`)
- `usd_price numeric not null`
- `as_of timestamptz not null`

Constraints:
- `usd_price > 0`

Client notes:
- The client should cache the latest snapshot in-memory and avoid frequent reads (many rows).
- Server refresh cadence is hourly; client conversions should be computed locally from the cached USD-pivot snapshot.

## Storage (buckets)

### `asset_icons` (public read)
Optional bucket for asset icons.

Object key convention:
- `assets/{asset_id}.png`
- `assets/{asset_id}.svg`

The client must treat icons as optional and fall back to a generic glyph.
