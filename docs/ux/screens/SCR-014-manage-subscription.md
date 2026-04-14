# SCR-014: Manage subscription

## Purpose
Allow users to view current plan status and manage/cancel their subscription via platform mechanisms (implementation TBD).

## Layout sections
- App bar: “Subscription”
- Status card
  - Current plan (Free/Paid)
  - Expiration/renewal date (if available)
- Actions
  - “Manage in App Store / Google Play” (if link-out)
  - “Restore purchases” (optional)

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar`
- needs component: `DSSnackBar` (errors)
- needs component: `DSSkeleton` (loading)

## Actions & navigation
- On entry: refresh entitlements/profile.
- Manage:
  - Link out to platform subscription management (provider-dependent).
- Restore purchases:
  - Trigger platform restore; refresh entitlements on completion.

## States
- Loading:
  - Refreshing entitlements.
- Error:
  - Entitlements refresh failure → show banner; treat as free tier for gating elsewhere.
- Success:
  - Show plan and relevant dates/status.

## Copy (key text)
- Title: “Subscription”
- Plan free: “Free plan”
- Plan paid: “Paid plan”
- Manage: “Manage subscription”
- Restore: “Restore purchases”
- Error: “Couldn’t verify subscription status.”

## Edge cases
- Provider not finalized:
  - Show a placeholder explanation and hide manage actions until implemented (but keep screen structure stable).

