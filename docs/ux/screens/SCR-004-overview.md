# SCR-004: Overview

## Purpose
Show the global total in base currency, breakdown by account, and missing-rate + offline indicators; serve as the main hub for drill-down.

## Layout sections
- Top app bar
  - Title: “Overview”
  - Base currency chip (tappable to Settings → Base currency)
  - Pull-to-refresh affordance
- Summary section
  - Global total (full total or `N/A`)
  - Partial total (only when missing rates)
  - “Rates updated at …” timestamp (or missing)
  - Offline indicator (if offline)
- Accounts breakdown
  - List of active accounts with totals
  - Archived accounts excluded by default (no toggle in MVP unless specified)
- Missing rates section (only when needed)
  - List of unpriced holdings (asset code + original amount)

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton` (empty-state CTAs)
- needs component: `DSAppBar` (with trailing actions)
- needs component: `DSTotalValue` (large total typography + skeleton loading)
- needs component: `DSListRow` (account row with trailing amount)
- needs component: `DSChip` (base currency pill)
- needs component: `DSInlineBanner` (offline / missing rates / errors)
- needs component: `DSSkeleton` (loading placeholders)
- needs component: `DSPullToRefresh` (or platform-native wrapper)

## Actions & navigation
- Tap account row → `SCR-007` (Account detail).
- Tap base currency chip → `SCR-012` (Base currency settings) via `SCR-009` (Settings) or direct.
- Empty-state CTAs:
  - No accounts → “Create account” → `SCR-006`.
  - Accounts exist but no assets → “Add asset” → `SCR-007` (choose account first) or `SCR-005`.
  - Assets exist but no balances → “Add balance” → `SCR-010` then `SCR-011`.
- Refresh:
  - Pull-to-refresh reloads accounts/assets/balances/rates and recomputes totals.

## States
- Loading:
  - Skeleton for totals and account rows.
  - Show cached snapshot immediately if available (prefer) while refreshing in background.
- Empty (progressive):
  - No accounts: show CTA “Create account”.
  - Has accounts, no assets: show guidance + CTA “Add asset”.
  - Has assets, no balances: show guidance + CTA “Add balance”.
- Error:
  - Network error while online: show retry banner.
  - Unauthorized: force sign-out → `SCR-002`.
  - Offline:
    - If cached snapshot exists → show snapshot + “Offline / Last updated”.
    - If no cache → offline empty/error state with “Try again”.
- Success:
  - Totals computed with Decimal math; rounding for display only.
  - Missing rates:
    - Show partial total + full total as `N/A`.
    - List unpriced holdings.

## Copy (key text)
- Title: “Overview”
- Global total label: “Total”
- Full total missing: “N/A”
- Partial total label (missing rates): “Priced total”
- Rates updated: “Rates updated at {time}”
- Rates missing: “Rates unavailable”
- Offline: “Offline”
- Offline detail: “Showing last saved totals from {time}.”
- Empty: “Create your first account”
- Empty CTA: “Create account”
- Retry: “Try again”
- Missing rates banner: “Some holdings can’t be priced right now.”

## Edge cases
- Missing rates for base currency itself:
  - Treat as missing-rate scenario; show `N/A` full total and list affected holdings.
- Archived accounts:
  - Exclude from default totals and list; if product later adds a toggle, ensure it is explicit.
- Large numbers / many decimals:
  - Use compact formatting rules (but keep full precision for calculations).

