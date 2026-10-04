# SPEC-0009: Paywall Cubit With Single Dismiss

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-003: after a successful purchase or restore the paywall closes exactly once, and the
paywall flow logic lives in a Cubit instead of the page `State`/`build()`.

## User Or Product Impact
A user who buys Pro from a feature gate (e.g. Add subaccount at the limit) returns to that screen
instead of being thrown one screen further back.

## Current Behavior
`client/lib/presentation/paywall/page/paywall_page.dart` keeps offerings, plan selection, purchase,
restore, analytics and dismissal in `_PaywallPageState`. The completion handler pops, then the
`finally` `setState` rebuilds; `build()` sees `isPro && !_isProcessingAction` and schedules a second
`context.pop` via `addPostFrameCallback`, which pops the route beneath. Commit `d60d052` only
covered the in-flight case.

## Desired Behavior
- `PaywallCubit` (`presentation/paywall/bloc/`) owns offerings loading and package selection,
  plan selection, purchase, restore, paywall analytics, and a terminal `done` status.
- The page pops only from a `BlocListener` on the transition into `done`; the Cubit reaches `done`
  at most once. `build()` has no side effects.
- Verification after a store success keeps the existing behavior: `ProfileCubit.syncSubscription`
  (forced), confirm Pro, refresh assets, then `done`; not Pro → entitlement error, paywall stays.
- A user who is already Pro when the paywall opens is dismissed as before.

## Scope
- New `PaywallCubit` + Freezed state; rewrite `PaywallPage` to use it.
- Widget test: restore success pops only the paywall.

## Out Of Scope
- Paywall visuals, copy, analytics event names/params.
- QA-006 (pending purchases), QA-010, QA-034, BL-0001.

## Constraints
- Follow the page-Cubit + `BlocListener` convention used by `AccountCreateCubit`.
- Cross-Cubit coordination (`ProfileCubit`, `AssetsCubit`) stays in page listeners, as elsewhere.
- No new dependencies.

## Acceptance Criteria
- [x] Widget test: stack Home → Form → Paywall, restore succeeds → Form is visible, Home is not.
- [x] No `context.pop` in `build()` or in `finally` blocks of the paywall.
- [x] `flutter analyze lib test` clean, `flutter test` green.

## Verification
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze lib test`
- `flutter test`
- Emulator check of the purchase flow at the next regression.

## Documentation Updates
- `docs/qa/findings.md`: QA-003 status.

## Rollout Notes
Ships with the next app build.

## Resolution Notes
- Emulator check of the real purchase flow is deferred to the next regression (QA-003 marked
  accordingly in `docs/qa/findings.md`).
