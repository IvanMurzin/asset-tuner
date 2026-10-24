# SPEC-0023: Paywall Store Unavailable

- **Type:** bug
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-034: when the store cannot sell (no store account, billing unavailable) or the offer cannot
be loaded, the paywall says so and offers Retry instead of showing `--` prices.

## Current Behavior
`PaywallCubit.loadOfferings` marks `offeringsLoaded = true` on failure and emits a one-shot
`paywall_load_offerings` snackbar; the offer stays on screen with `--` prices and a disabled button.
An offering without packages looks the same, silently.

## Desired Behavior
- `PaywallState.offerings` (`loading`, `loaded`, `storeUnavailable`, `failed`) replaces
  `offeringsLoaded`. `purchaseNotAllowedError`/`storeProblemError` → `storeUnavailable`; other
  errors or no packages → `failed`. `loadOfferings` can be retried.
- `resolvePaywallBody` maps both to `PaywallBodyOfferingsUnavailable`; the page shows an inline
  explanation ("Purchases unavailable…" or the existing "no subscription options") with Retry inside
  `PaywallScaffold` (close available, restore hidden). The snackbar path is removed.

## Acceptance Criteria
- [x] Cubit, body and page tests for both outcomes and retry.

## Verification
`flutter analyze lib test`, `flutter test`; emulator without a Play account at the next regression.

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Ships with the next app build.
