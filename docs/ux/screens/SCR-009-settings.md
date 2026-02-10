# SCR-009: Settings

## Purpose
Provide access to base currency settings and subscription management.

## Layout sections
- App bar: “Settings”
- Sections:
  - Preferences
    - Base currency row (shows current code)
  - Subscription
    - Plan status row (Free/Paid + expires info if available)
    - Manage subscription row

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton` (sign-out if included)
- needs component: `DSAppBar`
- needs component: `DSListRow` (settings row with trailing value)
- needs component: `DSInlineBanner` (entitlements refresh errors)

## Actions & navigation
- Tap “Base currency” → `SCR-012`.
- Tap “Manage subscription” → `SCR-014`.
- Optional: “Sign out” action → clears session → `SCR-002`.

## States
- Loading:
  - Loading profile/entitlements; show skeleton rows.
- Error:
  - If entitlements can’t be verified: show non-blocking banner, but still render Settings (treat as free tier for gating).
- Success:
  - Rows show current base currency and plan status.

## Copy (key text)
- Title: “Settings”
- Base currency: “Base currency”
- Subscription section: “Subscription”
- Plan (free): “Free plan”
- Plan (paid): “Paid plan”
- Manage: “Manage subscription”
- Sign out: “Sign out”
- Entitlements error: “Couldn’t verify subscription status.”

## Edge cases
- Entitlements unknown:
  - Treat as free tier for gating; make messaging non-blocking.

