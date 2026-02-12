# SCR-004: Main (MVP v2)

See also: `docs/ux/navigation.md`.

## Purpose
Show the global total in base currency and the list of accounts; serve as the primary hub.

Primary navigation:
- Bottom tabs: Main / Analytics / Profile.

## Layout sections
- Top app bar (no Settings icon)
  - Title: “Main”
  - Base currency chip (tappable → Profile → Base currency)
  - Pull-to-refresh affordance
- Global total section
  - Gradient card showing global total converted into base currency
  - Rates updated timestamp
  - Offline indicator (if offline)
- Accounts list
  - Gradient cards per account, styled by account type
  - Each card shows:
    - account name,
    - converted total in base currency,
    - count of subaccounts (счетов).
  - Primary CTA: “Add account” (floating or inline; must be prominent)

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton` (empty-state CTAs)
- needs component: `DSAppBar` (with trailing actions)
- needs component: `DSTotalValue` (large total typography + skeleton loading) or reuse DS typography
- needs component: `DSAccountCard` (gradient card by account type)
- needs component: `DSChip` (base currency pill)
- needs component: `DSInlineBanner` (offline / missing rates / errors)
- needs component: `DSSkeleton` (loading placeholders)
- needs component: `DSPullToRefresh` (or platform-native wrapper)

## Actions & navigation
- Tap account row → `SCR-007` (Account detail).
- Tap base currency chip → `SCR-012` (Base currency settings) via `SCR-009` (Profile).
- Empty-state CTAs:
  - No accounts → “Create account” → `SCR-006`.
  - Accounts exist but no subaccounts → open an account → “Add subaccount” (`SCR-008`).
  - Subaccounts exist but no balances → open a subaccount → “Update balance” (`SCR-011`).
- Refresh:
  - Pull-to-refresh reloads accounts/assets/balances/rates and recomputes totals.

## States
- Loading:
  - Skeleton for totals and account rows.
  - Show cached snapshot immediately if available (prefer) while refreshing in background.
- Empty (progressive):
  - No accounts: show CTA “Create account”.
  - Has accounts, no subaccounts: show guidance + CTA “Open an account to add subaccounts”.
  - Has assets, no balances: show guidance + CTA “Add balance”.
- Error:
  - Network error while online: show retry banner.
  - Unauthorized: force sign-out → `SCR-002`.
  - Offline:
    - If cached snapshot exists → show snapshot + “Offline / Last updated”.
    - If no cache → offline empty/error state with “Try again”.
- Success:
  - Totals computed with Decimal math; rounding for display only.
  - Missing rates (MVP v2):
    - Exclude holdings that cannot be priced from totals.
    - Analytics excludes them as well.

## Copy (key text)
- Title: “Main”
- Global total label: “Total”
- Rates updated: “Rates updated at {time}”
- Rates missing: “Rates unavailable”
- Offline: “Offline”
- Offline detail: “Showing last saved totals from {time}.”
- Empty: “Create your first account”
- Empty CTA: “Create account”
- Retry: “Try again”
 - Add account CTA: “Add account”

## Edge cases
- Missing rates for base currency itself:
  - Totals cannot be computed reliably; show a retryable error/banner.
- Archived accounts:
  - Exclude from default totals and list; if product later adds a toggle, ensure it is explicit.
- Large numbers / many decimals:
  - Use compact formatting rules (but keep full precision for calculations).
