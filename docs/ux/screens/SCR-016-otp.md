# SCR-016: OTP verification

## Purpose
Verify the user’s email after sign-up by entering an OTP.

## Layout sections
- App bar (minimal)
- Content
  - Hero title + instructions
  - OTP input
  - Primary CTA: “Verify”
  - Text link: “Change email”

## Components
- DS: `DSTextField` (OTP)
- DS: `DSButton` (primary + secondary + text variants)
- needs component: `DSInlineBanner` (non-blocking info/error messages)

## Actions & navigation
- Submit OTP:
  - Validate 6-digit format.
  - Verify OTP.
  - On success → navigate to `SCR-003` or `SCR-004`.
- Secondary:
  - “Change email” → `SCR-015`.

## States
- Default:
  - OTP input enabled.
- Loading:
  - Disable inputs; show progress in primary button.
- Error:
  - Invalid OTP: show safe error + retry.
  - Network/rate limited: show retry guidance.

## Copy (key text)
- Title: “Verify your email”
- Body: “Enter the 6-digit code we sent to {email}.”
- Primary CTA: “Verify”
- Secondary: “Change email”
