# Asset Tuner — API Surface (Supabase) — v2 (breaking)

This document defines the concrete client-facing API surface: Auth, PostgREST reads, Edge Function operations, filters/pagination, and the error model.

**Last updated:** 2026-02-14

## Versioning / breaking changes
This API surface is **v2** and is intentionally **breaking** vs earlier MVP drafts:
- Replace `account_assets` “asset positions” with **`subaccounts`** (unlimited, named).
- Replace “Add asset” and “Add balance (snapshot/delta)” flows with:
  - `create_subaccount` (creates subaccount + initial snapshot),
  - `update_subaccount_balance` (snapshot-only),
  - `rename_subaccount` and `delete_subaccount`.
- Analytics reads are based on snapshot updates.

## Base components
- Supabase project URL + anon key are provided to the client via `--dart-define-from-file` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Auth is handled via Supabase Auth.
- Reads use PostgREST where safe under RLS.
- Writes use Edge Functions for validation, limits, and atomic workflows.
- Simple row updates may use PostgREST under RLS when no extra server validation is needed.
- Money/rates fields are serialized as decimal strings in JSON (`"123.45"`), not JSON numbers.

## Error model (normalized in client)
All transport and API errors must be normalized by the client into:
`Failure { code: string, message: string }`

Allowed `Failure.code` values:
- `network`
- `unauthorized`
- `forbidden`
- `not_found`
- `validation`
- `conflict`
- `rate_limited`
- `unknown`

Edge Functions must return JSON on failures:
```json
{
  "error": {
    "code": "validation",
    "message": "Human-safe message",
    "details": { "field": "base_currency" }
  }
}
```

The client must never depend on `details` keys for correctness; they are for UX only.

## Auth (Supabase Auth)

Operations:
- Sign up (email + password) → triggers email confirmation / OTP flow (provider configuration dependent).
- Sign in (email + password).
- Sign in with OAuth (Google/Apple when configured).
- Sign out.
- Restore session on app start.

Contract notes:
- The client must not persist credentials.
- Session tokens are managed by the Supabase SDK.

## PostgREST reads (tables)

### `profiles`
- `GET profile`:
  - query: `profiles?select=*`
  - notes:
    - RLS guarantees the client only sees the current user’s row.
    - The client must not add `user_id` filters or pass user ids around.
  - returns: 0..1 row (client uses a singular read)

### `accounts`
- `LIST accounts`:
  - query: `accounts?select=*&order=updated_at.desc`
  - optional filters:
    - `archived=eq.true|false`

### `subaccounts`
- `LIST subaccounts for account`:
  - query: `subaccounts?account_id=eq.<account_id>&order=sort_order.asc.nullslast,created_at.asc`
- `COUNT subaccounts`:
  - query: `HEAD subaccounts` with `Prefer: count=exact` (no body)

### `assets`
- `LIST assets`:
  - query: `assets?select=*&order=kind.asc,code.asc`
  - notes:
    - RLS is plan-aware; visible rows depend on current plan (`free|paid`).
    - `anon` reads are allowed but treated as `free`.
- `LIST fiat assets` (for base currency pickers):
  - query: `assets?kind=eq.fiat&select=*&order=code.asc`

### `balance_entries`
- `LIST history for subaccount`:
  - query: `balance_entries?subaccount_id=eq.<id>&order=entry_date.desc,created_at.desc`
  - pagination: use range (inclusive) with `offset` + `limit`

### `asset_rates_usd`
- `GET latest rates snapshot`:
  - query: `asset_rates_usd?select=asset_id,usd_price,as_of`
  - notes:
    - RLS is plan-aware and mirrors visibility from `assets`.
    - rates for hidden assets are not returned.
  - client caching:
    - Treat this read as **expensive** (many rows) and avoid calling it frequently.
    - Cache the latest snapshot in-memory app-wide and persist last-known snapshot for offline start.
    - Refresh at most once per minute (soft TTL). Server updates rates hourly; the client should recalculate conversions locally using the cached USD-pivot snapshot.

## PostgREST writes (tables)

All PostgREST writes:
- Require an authenticated user (Bearer JWT).
- Rely on RLS for ownership (`user_id = auth.uid()`).
- Must not accept or require `user_id` from the client.

### `accounts`
- `UPDATE account` (name/type):
  - query: `accounts?id=eq.<account_id>`
  - body: `{ "name": "New name", "type": "bank" }`
  - returns: updated `accounts` row
- `SET archived`:
  - query: `accounts?id=eq.<account_id>`
  - body: `{ "archived": true }`
  - returns: updated `accounts` row

## Edge Functions (writes and workflows)

All Edge Functions:
- Require an authenticated user (Bearer JWT).
- Enforce ownership and business constraints.
- Return JSON on success and on error (see Error model).

### `POST /bootstrap_profile`
Ensures the current auth user has a valid `profiles` row and entitlements.

Request:
```json
{ }
```

Response:
```json
{
  "profile": {
    "user_id": "uuid",
    "base_currency": "USD",
    "plan": "free",
      "entitlements": {
        "max_accounts": 5,
        "max_subaccounts": 20,
        "any_base_currency": false,
        "allowed_base_currency_codes": ["USD", "EUR", "RUB"],
        "expires_at": null
      },
    "created_at": "timestamptz",
    "updated_at": "timestamptz"
  },
  "is_new": true,
  "was_base_currency_defaulted": true
}
```

### `POST /create_account`
Creates an account and enforces entitlement limits.

Request:
```json
{ "name": "Cash", "type": "cash" }
```

Response: `accounts` row.

Errors:
- `validation` (invalid name/type)
- `forbidden` with `details.reason = "accounts_limit"` when free-tier cap exceeded

### `DELETE /account`
Cascades delete: account + subaccounts + balance history.

Request:
```json
{ "account_id": "uuid" }
```

Response:
```json
{ "ok": true }
```

### `POST /create_subaccount`
Creates a subaccount (user-defined “счёт”) under an account and writes the initial balance snapshot for today.

Notes:
- `name` is required and not derived from currency.
- `asset_id` is immutable once created.

Request:
```json
{
  "account_id": "uuid",
  "name": "USDT (TRC20)",
  "asset_id": "uuid",
  "snapshot_amount": "200",
  "entry_date": "2026-02-12"
}
```

Response:
```json
{
  "subaccount": {
    "id": "uuid",
    "account_id": "uuid",
    "asset_id": "uuid",
    "name": "USDT (TRC20)",
    "archived": false,
    "sort_order": null,
    "created_at": "timestamptz",
    "updated_at": "timestamptz"
  },
  "balance_entry": {
    "id": "uuid",
    "subaccount_id": "uuid",
    "entry_date": "2026-02-12",
    "snapshot_amount": "200",
    "diff_amount": null,
    "created_at": "timestamptz"
  }
}
```

Errors:
- `validation` (missing/invalid fields; negative snapshot rules if any; unknown ids)
- `forbidden` with `details.reason = "subaccounts_limit"` when free-tier cap exceeded

### `POST /update_subaccount_balance`
Writes a **snapshot** balance entry for a subaccount and computes/stores `diff_amount` vs the previous snapshot (if any).

Request:
```json
{
  "subaccount_id": "uuid",
  "snapshot_amount": "0.001",
  "entry_date": "2026-02-12"
}
```

Response: `balance_entries` row.

Errors:
- `validation` (missing amount/date; invalid date)
- `not_found` (unknown subaccount or not owned)

### `POST /rename_subaccount`
Renames a subaccount. Currency (`asset_id`) is immutable and must not be updatable.

Request:
```json
{ "subaccount_id": "uuid", "name": "Bitcoin" }
```

Response: `subaccounts` row.

### `DELETE /subaccount`
Deletes a subaccount and cascades delete its `balance_entries`.

Request:
```json
{ "subaccount_id": "uuid" }
```

Response:
```json
{ "ok": true }
```

### `POST /update_base_currency`
Updates `profiles.base_currency` with entitlement enforcement.

Request:
```json
{ "base_currency": "CHF" }
```

Response: updated `profiles` row.

Errors:
- `forbidden` with `details.reason = "base_currency"` when the currency is not allowed for the current entitlements

### `POST /update_plan` (dev/testing only)
Updates `profiles.plan` and recomputes `profiles.entitlements`.

Request:
```json
{ "plan": "paid" }
```

Response: updated `profiles` row.

### `POST /rates_sync` (server-only)
Scheduled hourly (cron), secret-protected (`x-rates-sync-secret` or `{secret}` payload).

Behavior:
- Fetch OpenExchangeRates `latest.json` once per run.
- Fetch CoinGecko prices via `/simple/price` using cached ids (no hourly `/coins/list`).
- Upsert provider-layer tables (`fx_rates_usd`, `crypto_rates_usd`).
- Project latest prices into `asset_rates_usd`.

### `POST /coingecko_refresh_metadata` (server-only)
Scheduled weekly (cron), secret-protected (`x-rates-sync-secret` or `{secret}` payload).

Behavior:
- Refresh CoinGecko metadata caches:
  - `/coins/list` -> `cg_coins_cache`
  - `/coins/markets` -> `cg_top_coins`
- Run idempotent `assets` autofill:
  - fiat from `fx_rates_usd` (+ OER currencies names fallback),
  - crypto from top coins using stable `provider_ref` mapping.
