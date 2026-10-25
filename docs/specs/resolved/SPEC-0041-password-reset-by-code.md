# SPEC-0041: Password Reset By Code

- **Type:** feature
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-014: a user who forgot the password resets it in the app with a 6-digit code from email,
and the temporary "write to support" fallback (SPEC-0037, SPEC-0040) is removed.

## Current Behavior
"Forgot password?" opens a dialog with a support `mailto:` link, driven by an optional
`SUPPORT_EMAIL` config key that CI injected. Supabase Auth now sends email through Resend SMTP
(`noreply@murzinstudio.com`).

## Desired Behavior
- Sign in → "Forgot password?" opens `/reset-password` with `go` (not `push`) and the typed email.
  A `/sign-in` left underneath would be redirected to `/main` by the auth guard as soon as the code
  signs the user in, closing the page before the password is saved (caught on the emulator,
  covered by the router integration test). Back and the app-bar back go to Sign in explicitly.
- Step 1: email → "Send code" (`resetPasswordForEmail`).
- Step 2: 6-digit code, new password, confirmation → "Set new password"
  (`verifyOTP(type: recovery)` then `updateUser(password)`). Resend with a 60-second cooldown,
  "Change email" goes back to step 1. Supabase errors (`otp_expired`, `same_password`,
  `over_email_send_rate_limit`, …) are shown through the existing localized mapper.
- Success shows "Password updated. You're signed in." and goes to `/main`.
- `/reset-password` is public but not an auth-flow route, so the auth guard does not close it when
  the code signs the user in before the password is saved.
- If the code was verified but the password update failed, a retry reuses the session for that
  email instead of the single-use code.
- The recovery email template shows `{{ .Token }}` (en/ru, no links).
- Removed: `AppConfig.supportEmail`, `SUPPORT_EMAIL` in configs and examples, the CI step, the
  dialog, and its ARB keys.

## Scope
Auth data source, repository and interface; two use cases; `ResetPasswordCubit` and page; routes;
Sign in; config; CI workflow; ARB; docs; tests.

## Out Of Scope
Changing the password from Profile while signed in.

## Constraints
Clean architecture as in `client/CLAUDE.md`; no new dependencies.

## Acceptance Criteria
- [x] Cubit tests: validation, step changes, cooldown, failures, change email.
- [x] Repository tests: request and reset call the data source; `otp_expired` maps to a failure.
- [x] Guard test: `/reset-password` is not redirected for signed-in or signed-out users.
- [x] Router integration test: the page stays open when the user becomes authenticated.
- [x] Emulator 2026-10-25: code from the Resend email → new password → Main; API sign-in with the
  new password returns 200. Test user deleted.
- [x] `flutter analyze lib test` and `flutter test` pass.
- [x] Supabase recovery template uses `{{ .Token }}` (set 2026-10-25).

## Verification
`flutter analyze lib test`, `flutter test`; emulator: request a code for a test user, read the
email, reset, land on Main, sign in with the new password.

## Documentation Updates
`docs/product/capabilities.md`, `docs/ux/screen-map.md`, `docs/ux/navigation.md`,
`docs/qa/findings.md` (QA-014, QA-045).

## Rollout Notes
Ships with the next app build. Supabase Auth: Resend SMTP and the code template are already live;
set `site_url` to `https://murzinstudio.com` so no email links point at localhost.
