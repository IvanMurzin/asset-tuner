# SCR-015: Sign-up

## Purpose
Create a new account via email + password and send an OTP verification code.

## Layout sections
- App bar (minimal)
- Content
  - Hero title + short explanation
  - Email input
  - Password input
  - Confirm password input
  - Primary CTA: “Create account”
  - Text link to “Sign in”

## Components
- DS: `DSTextField` (email + password + confirm password)
- DS: `DSButton` (primary + secondary + text variants)
- needs component: `DSInlineBanner` (non-blocking info/error messages)

## Actions & navigation
- Submit sign-up:
  - Validate email + password format client-side.
  - Request OTP.
  - On success → navigate to `SCR-016` (OTP).
- Secondary:
  - “Sign in” → `SCR-002`.

## States
- Default:
  - Inputs enabled.
- Loading:
  - Disable inputs; show progress in primary button.
- Success:
  - Show “check your email” banner before navigating.
- Error:
  - Network/rate limited: show retry guidance.
  - Unknown: safe message + retry.

## Copy (key text)
- Title: “Create account”
- Body: “Join Asset Tuner to sync your portfolio.”
- Email label: “Email”
- Password label: “Password”
- Confirm password label: “Confirm password”
- Primary CTA: “Create account”
- Secondary: “Already have an account? Sign in”
