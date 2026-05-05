# Data Contract

This contract describes the current Supabase data model. Field names are exact.

## Profiles
`profiles`

| Field | Type | Notes |
|---|---|---|
| `user_id` | `uuid` | Primary key, references `auth.users(id)`, cascade delete. |
| `plan` | `text` | `free` or `pro`, default `free`. |
| `base_asset_id` | `uuid` | Nullable, references `assets(id)`, set null on delete. |
| `revenuecat_app_user_id` | `text` | Nullable. |
| `created_at` | `timestamptz` | Server timestamp. |
| `updated_at` | `timestamptz` | Server timestamp. |

## Assets
`assets`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `kind` | `text` | `fiat` or `crypto`. |
| `code` | `text` | Uppercase asset code. |
| `name` | `text` | Display name. |
| `provider` | `text` | Catalog provider. |
| `provider_ref` | `text` | Provider identifier. |
| `rank` | `int` | 1..100. |
| `decimals` | `smallint` | 0..18. |
| `is_active` | `boolean` | Active catalog visibility. |
| `created_at` | `timestamptz` | Server timestamp. |
| `updated_at` | `timestamptz` | Server timestamp. |

Unique: `(kind, code)`.

## Asset Rates
`asset_rates_usd`

| Field | Type | Notes |
|---|---|---|
| `asset_id` | `uuid` | Primary key, references `assets(id)`. |
| `usd_price_atomic` | `text` | Decimal-safe atomic price. |
| `usd_price_decimals` | `smallint` | 0..18. |
| `as_of` | `timestamptz` | Provider freshness timestamp. |
| `updated_at` | `timestamptz` | Server timestamp. |

## Plan Limits
`plan_limits`

| Field | Type | Notes |
|---|---|---|
| `plan` | `text` | Primary key, `free` or `pro`. |
| `max_accounts` | `int` | Nullable for unlimited. |
| `max_subaccounts` | `int` | Nullable for unlimited. |
| `fiat_limit` | `int` | Nullable for unlimited. |
| `crypto_limit` | `int` | Nullable for unlimited. |

## Accounts
`accounts`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `user_id` | `uuid` | References `auth.users(id)`, cascade delete. |
| `name` | `text` | Non-empty. |
| `type` | `text` | Non-empty account type. |
| `archived` | `boolean` | Default `false`. |
| `cached_total_usd_atomic` | `text` | Decimal-safe cached USD total. |
| `cached_total_usd_decimals` | `smallint` | Default `12`. |
| `cached_total_updated_at` | `timestamptz` | Nullable. |
| `created_at` | `timestamptz` | Server timestamp. |
| `updated_at` | `timestamptz` | Server timestamp. |

## Subaccounts
`subaccounts`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `user_id` | `uuid` | References `auth.users(id)`, cascade delete. |
| `account_id` | `uuid` | References `accounts(id)`, cascade delete. |
| `asset_id` | `uuid` | References `assets(id)`, delete restricted. |
| `name` | `text` | Non-empty. |
| `archived` | `boolean` | Default `false`. |
| `current_amount_atomic` | `text` | Current balance snapshot amount. |
| `current_amount_decimals` | `smallint` | 0..18. |
| `created_at` | `timestamptz` | Server timestamp. |
| `updated_at` | `timestamptz` | Server timestamp. |

## Balance Entries
`balance_entries`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `user_id` | `uuid` | References `auth.users(id)`, cascade delete. |
| `subaccount_id` | `uuid` | References `subaccounts(id)`, cascade delete. |
| `amount_atomic` | `text` | Snapshot amount. |
| `amount_decimals` | `smallint` | 0..18. |
| `note` | `text` | Nullable. |
| `created_at` | `timestamptz` | Server timestamp. |

## Support Messages
`support_messages`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `user_id` | `uuid` | Nullable, references `auth.users(id)`, set null on delete. |
| `email` | `text` | Nullable. |
| `subject` | `text` | Non-empty. |
| `message` | `text` | Non-empty. |
| `meta` | `jsonb` | Default `{}`. |
| `created_at` | `timestamptz` | Server timestamp. |

## Webhook Events
`webhook_events`

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key. |
| `source` | `text` | Webhook/source name. |
| `external_id` | `text` | Provider event id. |
| `received_at` | `timestamptz` | Server timestamp. |
| `payload` | `jsonb` | Raw provider payload. |

Unique: `(source, external_id)`.
