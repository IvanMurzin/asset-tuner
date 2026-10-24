# SPEC-0022: Apply Requested Base Currency After Purchase

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-021 / BL-0001: after buying Pro from a locked currency in the base-currency picker, that
currency becomes the base currency without picking it again.

## Current Behavior
`PaywallArgs.requestedBaseCurrencyCode` is written by the settings page and never read; the user has
to pick the currency and press Save again.

## Desired Behavior
The paywall stays unaware of base currencies. The settings page awaits the paywall; if currencies
are unlocked when it closes (`entitlements.anyBaseCurrency`), it selects and saves the requested
code via `ProfileCubit.updateBaseCurrency`. The dead `requestedBaseCurrencyCode` field is removed.

## Acceptance Criteria
- [x] Widget tests: buy → requested currency saved; close → nothing changes.

## Verification
`flutter analyze lib test`, `flutter test`.

## Documentation Updates
`docs/qa/findings.md`, `docs/backlog.md` (BL-0001 resolved).

## Rollout Notes
Ships with the next app build.
