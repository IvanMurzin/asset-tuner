# SPEC-0037: Forgot Password Via Support

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Mitigate QA-014 until reset emails can be delivered: a user who forgot the password has a visible
way to get help from the Sign in screen.

## Current Behavior
No "Forgot password?" link. Supabase Auth has no custom SMTP (the built-in sender only reaches
project team members) and `site_url` is `http://localhost:3000`, so a reset email cannot work yet.

## Desired Behavior
- New optional config key `SUPPORT_EMAIL` (`AppConfig.supportEmail`, empty by default).
- When it is set, Sign in shows "Forgot password?". It opens a dialog: write to support from the
  sign-up address; "Write email" opens a `mailto:` with the subject prefilled. The address is
  selectable in case no mail app is installed.
- When it is empty the link is hidden.

## Out Of Scope
A real reset flow: needs SMTP and a reset path (owner decision, follow-up).

## Acceptance Criteria
- [x] `SUPPORT_EMAIL` in both local configs and both examples.
- [x] `flutter analyze lib test` and `flutter test` pass.

## Verification
`flutter analyze lib test`, `flutter test`; emulator: Sign in → Forgot password? → dialog → mail
app or selectable address.

## Documentation Updates
`docs/qa/findings.md` (QA-014).

## Rollout Notes
CI builds (`client_build.yml`) add `SUPPORT_EMAIL` to the materialized config when the
`CONFIG_*_JSON` secret lacks it; the address is public, so it is not a secret.
A real reset flow is deferred: the owner chose not to set up SMTP for now (2026-10-25).
