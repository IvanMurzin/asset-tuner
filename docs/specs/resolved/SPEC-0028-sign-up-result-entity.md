# SPEC-0028: Sign-Up Result Entity

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Remove the test-only `SignUpCubit.testing` constructor and the Cubit's read of the global
`AppConfig.isOtpEnabled`.

## Current Behavior
`AuthRepository.signUpWithPassword` decides from config whether OTP follows, but returns only the
email; `SignUpCubit` re-reads `AppConfig.instance.isOtpEnabled` (overridable through a `.testing`
constructor) to choose the next step.

## Desired Behavior
`signUpWithPassword` returns a domain `SignUpResultEntity`: `otpRequired(email)` or `signedIn()`
(replaces `OtpVerificationEntity`). `SignUpCubit` switches on it; it no longer imports `AppConfig`
and has a single constructor. Tests drive the outcome through the fake repository.

## Acceptance Criteria
- [x] No `SignUpCubit.testing`; sign-up tests cover both outcomes.

## Verification
`flutter analyze lib test`, `flutter test`.

## Documentation Updates
None.

## Rollout Notes
Ships with the next app build.
