# SPEC-0030: Cancel OAuth On Return

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-008: when the user leaves the Google (or Apple) browser sign-in and comes back to the app,
Sign in and Sign up are usable again within seconds instead of after the 90-second timeout.

## User Or Product Impact
Everyone who opens social sign-in and changes their mind; this is the first screen of the app.

## Current Behavior
`AuthRepository.signInWithOAuth` waits for a `signedIn` auth event with a 90-second timeout. The
browser opens in full Chrome (`LaunchMode.platformDefault`), so back stays in Chrome history.

## Desired Behavior
- The auth page opens as a Custom Tab (`LaunchMode.inAppBrowserView`).
- After launching, the repository listens to app lifecycle changes. On `resumed` it starts a
  3-second grace timer; leaving the app again stops it. If no session arrives in time, the call
  fails with `oauth_cancelled`.
- Sign-in and sign-up cubits treat `oauth_cancelled` as a silent return to idle (no banner).
- A callback that lands after the cancel still signs the user in through `watchSession`.
- The 90-second timeout stays as the outer bound.

## Scope
`core/utils/app_lifecycle_signal.dart` (new), `AuthRepository`, `SupabaseAuthDataSource`,
`SupabaseModule`, `i_auth_repository.dart` (code constant), sign-in and sign-up cubits, tests.

## Out Of Scope
Native Google Sign-In (still the long-term option), Apple button visibility (QA-012).

## Constraints
No new dependencies. Presentation does not import data.

## Implementation Notes
`AppLifecycleSignal` wraps `AppLifecycleListener` as a broadcast stream and is injected into the
repository as an optional named dependency so existing constructor calls keep working.

## Acceptance Criteria
- [x] Resume without a session cancels with `oauth_cancelled`.
- [x] A callback inside the grace period succeeds.
- [x] Pausing again stops the grace timer.
- [x] A cancelled OAuth sign-up shows no banner.

## Verification
- `flutter analyze lib test`
- `flutter test test/data/auth test/presentation/auth`
- Emulator E14 at the next regression; device D1.

## Documentation Updates
`docs/qa/findings.md` (QA-008).

## Rollout Notes
Ships with the next app build.
