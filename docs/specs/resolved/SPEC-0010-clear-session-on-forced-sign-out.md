# SPEC-0010: Clear Session On Forced Sign-Out

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-005: after a 401 forces a sign-out, signing in again (same user) lands on Main.

## User Or Product Impact
Users whose session was revoked can sign back in without killing the app.

## Current Behavior
`AuthCubit.forceLocalSignOut` only flips cubit state and deliberately skips Supabase `signOut`.
The persisted session stays, `AuthRepository.watchSession` never emits `null`, and its
`.distinct()` drops the new session of the same user (`AuthSessionEntity` equality is
`userId` + `email`). The app stays on Sign in; on relaunch the stale session loops into 401s.

## Desired Behavior
- A 401 (`UnauthorizedNotifier`) triggers the regular `SignOutUseCase`; `forceLocalSignOut` and its
  separate state path are removed. gotrue 2.24 `signOut` (local scope) removes the session and emits
  `signedOut` before the server call and ignores a 401 there, so the session stream performs the
  transition exactly as for a user-initiated sign-out.
- Repeated 401s are harmless: `signOut` without a session is idempotent and `.distinct()` drops the
  duplicate `null`.
- Dropped: `AuthState.failureCode = 'unauthorized'` (no consumers) and the `reason: unauthorized`
  parameter of `signOutCompleted`.

## Scope
`client/lib/presentation/auth/bloc/auth_cubit.dart`, its tests, and `AuthCubit` fakes in tests.

## Out Of Scope
Repository `.distinct()` semantics, router, QA-013 (offline/timeouts).

## Acceptance Criteria
- [x] A 401 calls `signOut` and ends unauthenticated.
- [x] Same-user sign-in after a 401 ends authenticated.
- [x] `flutter analyze lib test` clean, `flutter test` green.

## Verification
- `flutter test test/presentation/auth/bloc/auth_cubit_test.dart`, `flutter analyze lib test`, `flutter test`
- Emulator repro from QA-005 at the next regression.

## Documentation Updates
`docs/qa/findings.md`: QA-005 status.

## Rollout Notes
Ships with the next app build.
