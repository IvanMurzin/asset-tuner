# SCR-001: Splash / session restore

## Purpose
Restore an existing Supabase session (if any), bootstrap the user profile, and route the user to the correct next screen.

## Layout sections
- Full-screen centered content
  - App logo/wordmark
  - Indeterminate loading indicator
  - Optional small status line (“Restoring session…”)

## Components
- needs component: `DSSplashLayout` (logo + progress + optional status)
- needs component: `DSLoadingIndicator` (indeterminate)
- needs component: `DSInlineError` (retryable full-screen error)
- DS: use tokens for spacing/typography/colors

## Actions & navigation
- On start:
  - Attempt session restore.
  - If restored:
    - Ensure `profiles` row exists (upsert).
    - Ensure `profiles.base_currency` exists (default `USD` if absent).
  - Route:
    - If unauthenticated → `SCR-002` (Sign-in).
    - If authenticated and onboarding requires base currency confirmation → `SCR-003`.
    - Else → `SCR-004` (Overview).
- Retry: if a transient error occurs during restore/bootstrap, show error state with “Try again”.

## States
- Loading:
  - “Restoring session…”
  - “Preparing your profile…”
- Error (retryable):
  - Show safe message + “Try again”.
  - If failure indicates unauthorized/invalid session → clear session and route to `SCR-002`.
- Success:
  - Immediate navigation; no lingering splash.

## Copy (key text)
- Title: “Asset Tuner”
- Loading: “Restoring session…”
- Loading (profile): “Preparing your profile…”
- Error: “Something went wrong.”
- Retry CTA: “Try again”

## Edge cases
- Session exists but profile bootstrap fails:
  - Keep user signed in; show retryable error.
  - Do not route into app until profile row exists (base currency + entitlements rely on it).
- Slow networks:
  - Avoid flicker: keep splash visible until routing decision is final.

