# FTR-001: Authentication and profile bootstrap

## Summary
Enable sign-in and sign-up with a persisted session, and ensure every user has a `profiles` row used for base currency and entitlements.

Source references:
- Product: `docs/prd/prd.md`, `docs/prd/requirements.md` (FR-001..FR-004, FR-010), `docs/prd/success_metrics.md` (activation funnel)
- Tech: `docs/tech/stack.md`, `docs/tech/integrations.md`, `docs/tech/api_assumptions.md`
- ADRs: `docs/adr/ADR-0001-tech-baseline.md`, `docs/adr/ADR-0002-edge-functions-api.md`

## User story
As a user, I want to sign in quickly and stay signed in, so that my accounts and balances sync across devices.

## Scope / Out of scope
Scope:
- Email + password sign-in.
- Email + password sign-up with OTP verification (email confirmation).
- OAuth sign-in via Google and Apple (if configured).
- Session persistence across app restarts.
- First-run profile bootstrap:
  - Create (or upsert) `profiles` row for the authenticated user.
  - Ensure a base currency exists (default to USD unless already set).

Out of scope:
- Crash reporting/analytics providers (not in MVP; see `docs/tech/integrations.md`).
- Supabase Realtime subscriptions (explicitly not in MVP; see `docs/tech/api_assumptions.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the app is launched and the user is not authenticated, when the user opens the app, then they are shown the Sign-in screen.
- Given the user signs in with email and password, when the credentials are valid, then the app establishes a session and navigates to the next onboarding step or the Main screen (depending on profile completeness).
- Given the user signs up with email and password, when the credentials are valid, then the app requests an OTP and shows a “check your email” state.
- Given the user completes OTP verification successfully, when the auth session is established, then the app navigates to the next onboarding step or the Main screen (depending on profile completeness).
- Given Google/Apple sign-in is configured, when the user signs in with Google/Apple successfully, then the app establishes a Supabase session and proceeds identically to OTP sign-in.
- Given the user is authenticated, when the app is killed and restarted, then the session is restored and the user is not asked to sign in again (unless the session is expired/invalid).
- Given a new authenticated user without an existing profile row, when the app completes sign-in, then it creates (or upserts) a `profiles` row with:
  - `user_id = auth.uid()`
  - `base_currency = "USD"` by default
- Given the app receives an auth/HTTP failure, when the data layer maps the error, then it yields a normalized `Failure { code, message }` using the codes in `docs/tech/api_assumptions.md`.

## UX references (which screens it touches; placeholders ok)
- Screen: Sign-in (email + password + optional “Continue with Google/Apple”)
- Screen: Sign-up (email + password + confirm password)
- Screen: OTP verification
- Screen: Loading/splash (session restore)
- Screen: Post-sign-in router (decides whether to show base currency selection or Main)

## States (loading/empty/error/success)
- Loading: restoring session; waiting for OTP verification; OAuth web flow.
- Empty: n/a.
- Error:
  - network / rate_limited (retry CTA)
  - unauthorized (force sign-out and return to Sign-in)
  - unknown (show safe message + “Try again”)
- Success: user authenticated; profile ensured.

## Data needs (entities + fields)
- `profiles` (user-owned; see `docs/tech/api_assumptions.md`)
  - `user_id: uuid` (PK or unique)
  - `base_currency: text` (ISO code)
  - `plan: text` (e.g., `free`/`paid`) or `entitlements: jsonb` (shape finalized by FTR-009)
  - `created_at, updated_at: timestamptz`

## Analytics (events, optional)
Optional local event logging (see logging guidance in `docs/adr/ADR-0002-edge-functions-api.md`):
- `auth_otp_requested { provider="email" }`
- `auth_sign_in_success { provider }`
- `auth_sign_in_failure { provider, failure_code }`
- `auth_session_restored { result }`

## Open questions (if any)
- Resolved for MVP: if the profile bootstrap defaults `base_currency` to USD, route to `SCR-003` so the user can confirm or change it immediately. The screen includes “Use USD for now” to skip selection and continue.
