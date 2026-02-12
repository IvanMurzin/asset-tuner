# SCR-009: Profile (MVP v2)

See also: `docs/ux/navigation.md`.

## Purpose
Provide access to user preferences and account-level settings, including base currency and subscription (if enabled).

## Layout sections
- App bar: “Profile”
- Sections:
  - Preferences
    - Base currency row (shows current code)
    - Language row
    - Theme row
  - Subscription (optional)
    - Plan status row
    - Manage subscription row
  - Account
    - Sign out

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
- Title: “Profile”
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
