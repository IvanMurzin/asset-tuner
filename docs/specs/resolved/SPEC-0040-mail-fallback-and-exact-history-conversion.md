# SPEC-0040: Mail Fallback And Exact History Conversion

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-045 and QA-046 from the final emulator check.

## Current Behavior
- "Forgot password?" → "Write email" with no mail app closes the dialog silently, so the support
  address is lost.
- Subaccount history converts with a factor rounded to 18 decimals (`converted / current`) and
  then multiplies; with a 24-digit balance the row differs from the header in the last digits.

## Desired Behavior
- When `launchUrl(mailto:)` fails or returns false, the address is copied to the clipboard and an
  info snackbar says so (en/ru `forgotPasswordAddressCopied`).
- History rows use `convertAtCurrentRate(amount, current, converted)`, which multiplies before
  dividing.

## Acceptance Criteria
- [x] Conversion test: the current balance converts to exactly the header value.
- [x] `flutter analyze lib test` and `flutter test` pass.

## Verification
`flutter analyze lib test`, `flutter test`; emulator with mail apps disabled at the next regression.

## Documentation Updates
`docs/qa/findings.md` (QA-045, QA-046).

## Rollout Notes
Ships with the next app build.
