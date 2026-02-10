# SCR-008: Add asset (catalog search/select)

## Purpose
Add a supported asset (fiat or crypto) from the backend catalog into a specific account.

## Layout sections
- App bar
  - Title: “Add asset”
  - Close/back
- Search
  - Search field
  - Optional filters (Fiat/Crypto) — optional for MVP
- Results list
  - Rows with asset code/symbol, name, kind (fiat/crypto)
  - Selected state
- Footer
  - Primary CTA: “Add”

## Components
- DS: `DSButton`
- DS: `DSCard`
- needs component: `DSAppBar`
- needs component: `DSSearchField` (wrap `DSTextField`)
- needs component: `DSListRow` (asset row with selected state)
- needs component: `DSEmptyState` (no results)
- needs component: `DSInlineBanner` (errors + paywall explanation)
- needs component: `DSSkeleton` (catalog loading)

## Actions & navigation
- On entry: fetch catalog (read-only).
- Search:
  - Matches code/symbol/name.
- Select an asset:
  - If already present in account → show validation error and disable “Add”.
- Add:
  - If free-tier positions limit would be exceeded → show `SCR-013` paywall (reason “asset positions limit”) and do not create.
  - Else create account-asset pair and return to `SCR-007`.

## States
- Loading:
  - Catalog fetch; show skeleton.
- Empty:
  - No results for search → “No matches”.
  - Catalog empty → treat as error (expected non-empty).
- Error:
  - Retryable error with “Try again”.
- Success:
  - Results list interactive; add operation updates account detail.

## Copy (key text)
- Title: “Add asset”
- Search hint: “Search by code or name”
- Add: “Add”
- Duplicate error: “This asset is already in the account.”
- No results: “No matches”
- Paywall preface: “Upgrade to add more tracked assets.”
- Retry: “Try again”

## Edge cases
- Very large catalog:
  - Debounce search and/or paginate results (implementation detail).
- Offline:
  - Disable add and show banner; allow viewing cached catalog only if available (optional).

