# FTR-010: Analytics — currency breakdown + balance updates feed (MVP v2)

## Summary
Provide an Analytics tab with:
1) a chart of holdings breakdown by currency/token (priced holdings only), and
2) a feed of balance updates (snapshot diffs) showing changes in the subaccount currency and in the user base currency.

Source references:
- Product: `docs/prd/requirements.md` (FR-080..FR-081)
- Contracts: `docs/contracts/data_contract.md`, `docs/contracts/api_surface.md`
- Rates: `docs/features/FTR-007-rates-sync-and-rates-read.md`

## User story
As a user, I want to see how my portfolio is distributed and what changed recently, without digging into each account.

## Scope / Out of scope
Scope:
- Currency breakdown chart:
  - Group by `asset.code`.
  - Use priced holdings only (if a holding cannot be priced, it is excluded from this chart).
  - Values are expressed in the user base currency.
- Updates feed:
  - Built from `balance_entries` snapshots.
  - Each feed item includes:
    - account name,
    - subaccount name,
    - asset code,
    - diff in asset units (`diff_amount`),
    - diff in base currency (computed using latest rates snapshot).
  - Feed order: newest first by `entry_date desc, created_at desc`.

Out of scope:
- Time-series charts and advanced analytics (post-MVP).
- Showing unpriced holdings/updates inside Analytics (explicitly excluded in MVP v2).

## Acceptance Criteria (BDD-style)
- Given the user opens Analytics, when data loads successfully, then:
  - the breakdown chart renders based on the latest balances per subaccount,
  - the updates feed renders the newest balance updates first.
- Given a subaccount has only one snapshot (no previous snapshot), when the snapshot exists, then:
  - it may appear in the feed with no diff (or be excluded); behavior must be consistent and documented in the UI copy.
- Given an update cannot be priced (missing rate for the asset or for base currency), when Analytics renders, then:
  - that update is excluded from the feed in MVP v2.
- Given the user is offline, when Analytics opens, then:
  - if cached analytics data exists, show it with an “Offline / Last updated” indicator,
  - otherwise show an offline empty/error state with retry.

## Data needs
Inputs:
- `profiles.base_currency`
- `accounts`
- `subaccounts` + `assets` (for asset codes)
- `balance_entries` (for current balances and diffs)
- `asset_rates_usd` (latest snapshot + `as_of`)

Derived rules:
- “Current balance” for each subaccount: the latest snapshot by `entry_date desc, created_at desc`.
- Breakdown chart uses converted values of current balances grouped by `asset.code`.
- Feed uses `balance_entries.diff_amount`:
  - If `diff_amount` is null (first snapshot), implementation may omit it from the feed or show “Initial balance” (choose one and keep consistent).

## UI states
- Loading: skeleton chart + skeleton list.
- Empty:
  - No accounts/subaccounts yet → show guidance and CTA “Add account”.
  - No balance history yet → show guidance and CTA “Update balance”.
- Error: network/unauthorized/unknown with retry.
- Offline: cached snapshot with “Offline” banner (optional).

## UX references
- Screen: Analytics tab (see `docs/ux/screens/SCR-017-analytics.md`)
