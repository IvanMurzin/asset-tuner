# SCR-002: Sign-in

## Purpose
Authenticate the user via Supabase email OTP, with optional Google/Apple sign-in if configured.

## Layout sections
- App bar (optional; minimal)
- Content
  - Title + short explanation
  - Email input
  - Primary CTA: “Send code” / “Send link”
  - Secondary: OAuth buttons (if available)
  - Support text (privacy / terms links optional; non-blocking)

## Components
- DS: `DSTextField` (email)
- DS: `DSButton` (primary + secondary + text variants)
- needs component: `DSOAuthButton` (Google/Apple branded buttons)
- needs component: `DSInlineBanner` (non-blocking info/error messages)
- needs component: `DSFullScreenLoader` (blocking loading state, if required)

## Actions & navigation
- Submit email OTP request:
  - Validate email format client-side (basic).
  - Call Supabase OTP request.
  - On success → show “Check your email” success state (no navigation required).
- Complete verification:
  - If using magic link: app receives link → establishes session → navigate to `SCR-003` or `SCR-004`.
  - If using code entry: needs component/screen for code entry (out of scope unless OTP requires it).
- OAuth:
  - If configured, tapping Google/Apple starts provider flow.
  - On success → same post-auth routing as OTP.

## States
- Default:
  - Email entry enabled; OAuth buttons visible if configured.
- Loading:
  - Disable inputs; show progress in primary button.
- Success (“Check your email”):
  - Keep the email field (read-only or editable) and show guidance.
  - Provide “Resend” (rate-limited) and “Change email”.
- Error:
  - Network/rate limited: show retry guidance.
  - Unknown: safe message + retry.

## Copy (key text)
- Title: “Sign in”
- Body: “Track your assets across devices.”
- Email label: “Email”
- Email hint: “name@example.com”
- Primary CTA: “Send code”
- Success title: “Check your email”
- Success body: “We sent a sign-in link to {email}.”
- Resend: “Resend”
- Change email: “Change email”
- OAuth: “Continue with Google”, “Continue with Apple”
- Error (generic): “Couldn’t sign in. Try again.”
- Error (rate limited): “Too many attempts. Please wait and try again.”

## Edge cases
- OAuth not configured:
  - Hide OAuth section entirely (avoid disabled buttons).
- Deep link already consumed/expired:
  - Show error banner and return user to default state.
- Keyboard + safe area:
  - Ensure primary CTA remains reachable (scroll content).

