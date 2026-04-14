# SCR-013: Paywall

## Purpose
Explain why an action is locked on the free tier and offer subscription purchase (monthly/annual) to unlock it.

## Layout sections
- Header
  - Title (“Upgrade”)
  - Reason-specific subtitle (accounts limit / subaccounts limit / base currency)
- Value proposition
  - Bulleted list of what paid unlocks
- Plan selection
  - Monthly plan card
  - Annual plan card (recommended badge)
- Footer
  - Primary CTA: “Upgrade”
  - Secondary: “Not now”
  - Optional: “Restore purchases” (platform-dependent)
  - Fine print (no free trial)

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar` or modal header with close
- needs component: `DSPlanCard` (selectable plan option)
- needs component: `DSSnackBar` (entitlements verification error, purchase errors)
- needs component: `DSLoadingOverlay` (purchase in progress)

## Actions & navigation
- Entry:
  - Launched from a gated action; must carry context:
    - reason: `accounts_limit` | `subaccounts_limit` | `base_currency`
    - attempted action metadata (optional)
- Upgrade:
  - Starts purchase flow for selected plan.
  - On success:
    - Refresh entitlements.
    - Close paywall and return user to the originating screen to retry.
- Not now / close:
  - Dismiss and return to previous screen without applying the blocked change.
- If entitlements cannot be verified:
  - Treat as free; if user is currently blocked, show non-blocking message and keep paywall available.

## States
- Loading:
  - Loading products/prices (if required by store APIs).
  - Purchase in progress (disable close to prevent inconsistent state; optional).
- Error:
  - Purchase failed: show error message + retry.
  - Entitlements refresh failed: show banner “Couldn’t verify subscription; try again” and keep user blocked until verified.
- Success:
  - Entitlement active; return-to-context.

## Copy (key text)
- Title: “Upgrade”
- Reason (accounts): “You’ve reached the free limit of 5 accounts.”
- Reason (subaccounts): “You’ve reached the free limit of 20 subaccounts.”
- Reason (base currency): “Unlock any base currency.”
- Unlock list:
  - “More accounts”
  - “More subaccounts”
  - “Any base currency”
- Primary CTA: “Upgrade”
- Secondary CTA: “Not now”
- Error entitlements: “Couldn’t verify subscription; try again.”
- No trial: “No free trial in MVP.”

## Edge cases
- User already paid but client is stale:
  - Provide “Refresh”/“Restore” action and re-check entitlements.
- Subscription cancelled/expired:
  - Screen should still allow purchase; existing data remains visible elsewhere.
