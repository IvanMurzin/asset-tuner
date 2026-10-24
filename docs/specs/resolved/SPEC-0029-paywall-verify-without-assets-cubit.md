# SPEC-0029: Paywall Verify Without AssetsCubit

- **Type:** bug
- **Status:** Resolved
- **Priority:** P0
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-035: after a successful purchase or restore the paywall must verify Pro and close instead
of hanging on the verifying spinner.

## User Or Product Impact
Every paying user. Today they pay, the paywall never closes, Close is disabled, and the app shows
Free until a manual pull to refresh.

## Current Behavior
`_verifyPro` in `client/lib/presentation/paywall/page/paywall_page.dart` reads `AssetsCubit`.
`/paywall` is a top-level route (`app_router.dart`), while `AssetsCubit` is only provided inside
`MainShellPage`, so the read throws `ProviderNotFoundError` and `onVerified` never runs. The page
tests provided `AssetsCubit` above the page, so they did not match the app tree.

## Desired Behavior
- `_verifyPro` reads only app-level cubits (`PaywallCubit`, `ProfileCubit`).
- `onVerified` always runs, even when the subscription sync throws; a failed sync leaves the
  paywall usable with the existing "Couldn't verify subscription" message.
- Assets refresh after the upgrade stays with `MainShellPage`, which already refreshes them on
  every ready profile change.

## Scope
`paywall_page.dart`, `paywall_page_test.dart`.

## Out Of Scope
Paywall cubit states, routing, the base-currency apply flow.

## Constraints
No new providers at app level.

## Implementation Notes
Remove the `AssetsCubit` read and wrap the sync in `try/catch/finally`. Remove the `AssetsCubit`
provider from the page tests so they mirror the real route tree.

## Acceptance Criteria
- [x] Restore test passes without an `AssetsCubit` provider (fails on the old code).
- [x] A throwing sync leaves the paywall open with the verification error (fails on the old code).

## Verification
- `flutter analyze lib test`
- `flutter test test/presentation/paywall`
- Emulator E8, E10, E23–E25 at the next regression.

## Documentation Updates
`docs/qa/findings.md` (QA-035).

## Rollout Notes
Ships with the next app build.
