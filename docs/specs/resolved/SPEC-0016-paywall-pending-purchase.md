# SPEC-0016: Paywall Pending Purchase

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-006: a pending Google Play payment is reported as pending, not as an error.

## Current Behavior
`PaywallCubit.purchase` sends `PurchasesErrorCode.paymentPendingError` down the generic failure
branch: an error snackbar with the raw SDK message, paywall stays open.

## Desired Behavior
- `PaywallStatus.pending` is a second terminal status next to `done`; `PaywallState.isTerminal`
  replaces the scattered `== done` guards.
- `paymentPendingError` → `pending`. The page shows an info snackbar ("payment is processing, Pro
  turns on automatically") and closes the paywall. Pro arrives through the existing paths
  (`CustomerInfo` listener in `ProfileCubit`, webhook, resume sync).
- Purchase errors map to the next state in one `switch` on the error code.
- Analytics unchanged (`purchaseFailed` with `failure_code = paymentPendingError`).

## Scope
`paywall_state.dart`, `paywall_cubit.dart`, `paywall_page.dart`, EN/RU strings, tests.

## Acceptance Criteria
- [x] Cubit: pending error → `pending`, terminal, no failure code; later events ignored.
- [x] Page: pending → info snackbar and the paywall closes once.
- [ ] Device case P3 at the next regression.

## Verification
`flutter analyze lib test`, `flutter test`; device P3.

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Ships with the next app build.
