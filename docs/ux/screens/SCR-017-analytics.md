# SCR-017: Analytics (MVP v2)

## Purpose
Show a simple analytics view:
- a chart of holdings breakdown by currency/token (priced holdings only),
- a feed of balance updates (priced updates only).

## Layout sections
- App bar
  - Title: “Analytics”
- Breakdown section
  - Donut/pie chart (base currency values)
  - Legend list: asset code + percent + value in base currency
- Updates section
  - List of update cards:
    - account name
    - subaccount name
    - asset code
    - diff in asset units
    - diff in base currency
    - date

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSListRow` (legend rows / update rows)
- needs component: `DSChartDonut` (or a minimal chart wrapper)
- needs component: `DSSkeleton` (loading)
- needs component: `DSInlineBanner` (offline/error)
- needs component: `DSEmptyState`

## Actions & navigation
- Tapping an update item (optional): navigate to `SCR-010` (Subaccount detail) for context.
- Pull-to-refresh: reload underlying data and recompute.

## States
- Loading: show skeleton chart + skeleton list.
- Empty:
  - No accounts/subaccounts → show CTA “Add account” (→ `SCR-006`).
  - No balance history yet → show CTA “Update balance” (→ open first subaccount then `SCR-011`).
- Error: show retry.
- Offline: show cached data if available + “Offline” banner.

## Copy (key text)
- Title: “Analytics”
- Breakdown title: “Breakdown”
- Updates title: “Updates”
