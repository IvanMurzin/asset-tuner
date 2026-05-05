# API Surface

The Flutter client calls Supabase Edge Functions through `SupabaseEdgeFunctions`.

## Envelope
Successful responses use:

```json
{
  "ok": true,
  "data": {},
  "meta": {}
}
```

Failures use:

```json
{
  "ok": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human readable safe message",
    "details": {}
  }
}
```

Client route constants live in `client/lib/core/supabase/supabase_constants.dart`.
Server routing lives in `backend/supabase/functions/api/index.ts`.

## Authenticated API Function
Base function path:

```text
https://<project-ref>.supabase.co/functions/v1/api
```

All routes below require a user JWT.

| Method | Client constant | Path | Purpose |
|---|---|---|---|
| `GET` | `me` | `api/me` | Load profile, plan limits, and base asset. |
| `POST` | `profileUpdate` | `api/profile/update` | Update `profiles.base_asset_id`. |
| `POST` | `deleteMyAccount` | `api/delete_my_account` | Delete the current auth user and cascade user data. |
| `POST` | `contactDeveloper` | `api/contact_developer` | Store a support message. |
| `GET` | `assetsList` | `api/assets/list` | List catalog assets by optional `kind`, includes lock state. |
| `GET` | `ratesUsd` | `api/rates/usd` | Read latest USD rates for asset ids. |
| `GET` | `analyticsSummary` | `api/analytics/summary` | Load analytics breakdown and update feed. |
| `GET` | `accountsList` | `api/accounts/list` | List user accounts. |
| `POST` | `accountsCreate` | `api/accounts/create` | Create account. |
| `POST` | `accountsUpdate` | `api/accounts/update` | Update account fields, including archive state. |
| `POST` | `accountsDelete` | `api/accounts/delete` | Delete account. |
| `GET` | `subaccountsList` | `api/subaccounts/list` | List subaccounts for an account. |
| `POST` | `subaccountsCreate` | `api/subaccounts/create` | Create subaccount with initial amount. |
| `POST` | `subaccountsUpdate` | `api/subaccounts/update` | Update subaccount name or archive state. |
| `POST` | `subaccountsDelete` | `api/subaccounts/delete` | Delete subaccount. |
| `POST` | `subaccountsSetBalance` | `api/subaccounts/set_balance` | Write a new balance snapshot. |
| `GET` | `subaccountsHistory` | `api/subaccounts/history` | Read paginated subaccount balance history. |
| `POST` | `revenuecatRefresh` | `api/revenuecat/refresh` | Refresh RevenueCat subscriber state into backend plan state. |

## Important Request Shapes

### `GET api/assets/list`
Query:

| Field | Type | Notes |
|---|---|---|
| `kind` | `fiat` or `crypto` | Optional. |
| `limit` | integer | Optional, max 100. |

### `GET api/rates/usd`
Query:

| Field | Type | Notes |
|---|---|---|
| `assetIds` | comma-separated UUIDs | Required. |

### `POST api/accounts/create`
Body:

| Field | Type |
|---|---|
| `name` | string |
| `type` | string |

### `POST api/accounts/update`
Body:

| Field | Type | Notes |
|---|---|---|
| `accountId` | UUID | Required. |
| `name` | string | Optional. |
| `type` | string | Optional. |
| `archived` | boolean | Optional. |

At least one update field is required.

### `POST api/subaccounts/create`
Body:

| Field | Type |
|---|---|
| `accountId` | UUID |
| `assetId` | UUID |
| `name` | string |
| `initialAmountAtomic` | string |
| `initialAmountDecimals` | integer |

### `POST api/subaccounts/update`
Body:

| Field | Type | Notes |
|---|---|---|
| `subaccountId` | UUID | Required. |
| `name` | string | Optional. |
| `archived` | boolean | Optional. |

At least one update field is required.

### `POST api/subaccounts/set_balance`
Body:

| Field | Type | Notes |
|---|---|---|
| `subaccountId` | UUID | Required. |
| `amountAtomic` | string | Required. |
| `amountDecimals` | integer | Required. |
| `note` | string | Optional. |

### `GET api/subaccounts/history`
Query:

| Field | Type | Notes |
|---|---|---|
| `subaccountId` | UUID | Required. |
| `cursor` | ISO timestamp | Optional. |
| `limit` | integer | Optional, max 200. |

Response `meta.nextCursor` contains the next cursor or `null`.

### `GET api/analytics/summary`
Query:

| Field | Type | Notes |
|---|---|---|
| `updatesLimit` | integer | Optional, max 500. |

## Server-Only Functions

### `rates_sync`
Called by scheduler, not the Flutter client.

Header:

```text
x-scheduler-secret: <SCHEDULER_SECRET>
```

### `revenuecat_webhook`
Called by RevenueCat.

Header:

```text
Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>
```

## Error Codes
The backend maps database and validation errors to stable API codes, including:

- `VALIDATION_ERROR`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `NOT_FOUND`
- `LIMIT_ACCOUNTS_REACHED`
- `LIMIT_SUBACCOUNTS_REACHED`
- `ASSET_NOT_ALLOWED_FOR_PLAN`
- `RATE_LIMITED`
- `EXTERNAL_API_ERROR`
- `INTERNAL_ERROR`
