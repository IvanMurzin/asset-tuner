# SCR-003: Onboarding — base currency

## Purpose
Confirm or set the user’s base currency immediately after first sign-in (optional flow). Defaults to USD if not set.

## Layout sections
- App bar (optional: “Back” disabled)
- Content
  - Title + explanation of “base currency”
  - Base currency picker (fiat catalog)
  - Primary CTA: “Continue”
  - Secondary CTA: “Use USD for now” (optional; if product allows skipping)

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSSelectList` (single-select list with search)
- needs component: `DSSearchField` (catalog search; could wrap `DSTextField`)
- needs component: `DSRadioRow` (selected currency row)
- needs component: `DSInlineError` (catalog load error with retry)

## Actions & navigation
- Load fiat catalog on entry.
- Select currency:
  - Free tier: USD/EUR/RUB selectable; other currencies trigger `SCR-013` paywall (reason “base currency”) and do not persist.
  - Paid entitlement: any fiat selectable and persisted.
- Continue:
  - Persists selection (if changed and permitted).
  - Navigates to `SCR-004` (Main).

## States
- Loading:
  - Fetching catalog.
  - Saving selection (disable CTAs).
- Error:
  - Retryable error if catalog fails.
- Success:
  - Currency selected and user continues.

## Copy (key text)
- Title: “Choose your base currency”
- Body: “Totals will be converted to this currency.”
- Continue: “Continue”
- Optional skip: “Use USD for now”
- Error: “Couldn’t load currencies.”
- Retry: “Try again”

## Edge cases
- Catalog returns empty:
  - Treat as error (catalog expected non-empty).
- Entitlements unknown at onboarding time:
  - Treat as free tier for safety; show a non-blocking banner if paywall blocks and entitlements couldn’t be verified.
