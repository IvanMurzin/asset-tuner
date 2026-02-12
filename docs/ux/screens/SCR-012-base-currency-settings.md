# SCR-012: Base currency settings

## Purpose
Allow the user to change their base currency, enforcing free-tier limits and reflecting changes in Main totals.

## Layout sections
- App bar: “Base currency”
- Current selection card
  - Current base currency code/name
- Picker list
  - Search field
  - Fiat catalog list (single-select)
- Footer
  - Primary CTA: “Save”

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar`
- needs component: `DSSelectList` (single-select list with search)
- needs component: `DSSearchField`
- needs component: `DSRadioRow`
- needs component: `DSInlineBanner` (paywall prompt, entitlements warning, errors)
- needs component: `DSSkeleton` (loading)

## Actions & navigation
- On entry:
  - Fetch fiat catalog.
  - Load current base currency from profile.
- Select currency:
  - Free tier:
    - USD/EUR/RUB allowed.
    - Other fiat selection triggers `SCR-013` paywall (reason “base currency”) and does not change selection in profile.
  - Paid entitlement: any fiat allowed.
- Save:
  - Persist selection (if changed and allowed).
  - Navigate back to Profile or Main.

## States
- Loading:
  - Fetching catalog; saving selection.
- Empty:
  - Catalog empty → show error state (expected non-empty).
- Error:
  - Retryable error when loading catalog.
- Success:
  - Saved selection causes `SCR-004` totals to recompute on next refresh (or immediately if Main is listening).

## Copy (key text)
- Title: “Base currency”
- Save: “Save”
- Error: “Couldn’t load currencies.”
- Retry: “Try again”
- Paywall hint: “Upgrade to unlock more base currencies.”

## Edge cases
- Entitlements can’t be verified:
  - Treat as free tier for safety.
  - If user is blocked by paywall, show non-blocking message: “Couldn’t verify subscription; try again.”
