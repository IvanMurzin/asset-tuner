# SCR-002: Sign-in

## Purpose
Authenticate the user via email + password, with optional Google/Apple sign-in if configured.

## Layout sections
- App bar (minimal)
- Content
  - Hero title + short explanation
  - Email input
  - Password input
  - Primary CTA: “Sign in”
  - Secondary: OAuth buttons (if available)
  - Text link to “Create account”

## Components
- DS: `DSTextField` (email + password)
- DS: `DSButton` (primary + secondary + text variants)
- needs component: `DSOAuthButton` (Google/Apple branded buttons)
- needs component: `DSSnackBar` (non-blocking info/error messages)

## Actions & navigation
- Submit sign-in:
  - Validate email + password format client-side.
  - Call sign-in endpoint.
  - On success → navigate to `SCR-003` or `SCR-004`.
- OAuth:
  - If configured, tapping Google/Apple starts provider flow.
  - On success → same post-auth routing as email/password.
- Secondary:
  - “Create account” → `SCR-015`.

## States
- Default:
  - Email + password entry enabled; OAuth buttons visible if configured.
- Loading:
  - Disable inputs; show progress in primary button.
- Error:
  - Network/rate limited: show retry guidance.
  - Unknown: safe message + retry.

## Copy (key text)
- Title: “Sign in”
- Body: “Track your assets across devices.”
- Email label: “Email”
- Email hint: “name@example.com”
- Password label: “Password”
- Password hint: “At least 6 characters”
- Primary CTA: “Sign in”
- OAuth: “Continue with Google”, “Continue with Apple”
- Error (generic): “Couldn’t sign in. Try again.”
- Error (rate limited): “Too many attempts. Please wait and try again.”
- Secondary: “New here? Create account”

## Edge cases
- OAuth not configured:
  - Hide OAuth section entirely (avoid disabled buttons).
- Invalid credentials:
  - Show safe error banner; keep inputs editable.
- Keyboard + safe area:
  - Ensure primary CTA remains reachable (scroll content).
  - Tap outside input dismisses keyboard via DS input callback (`onTapOutside`).
