# SPEC-0015: Paywall Close In Every State

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-010: the paywall can be closed from every state, and the page is split into clear parts
instead of one build method with early-returned bare scaffolds.

## Current Behavior
`PaywallPage` nests three `BlocBuilder`s and early-returns a bare `Scaffold` for "RevenueCat identity
not ready", "profile loading" and "profile error". Those states have no header, so only Android back
leaves them (the automatic first-auth paywall included). The offer layout, price formatting and
gating all live in one 360-line state class.

## Desired Behavior
- `resolvePaywallBody` (pure) maps auth, profile and paywall state to a sealed `PaywallBody`:
  identity error, profile loading, profile error, closing, offer.
- `PaywallScaffold` is the single layout: header with close (always) and restore (offer only) above
  the body. Close goes through `PaywallCubit.dismiss`, so the single-pop rule holds.
- `PaywallOfferView` renders the offer (hero, plans, footer, legal) and owns price formatting.
- `PaywallHeader` hides restore when no handler is given.
- `ProfileState.isPro` replaces the duplicated "ready and Pro" helpers (paywall, manage
  subscription).

## Out Of Scope
Visual changes to the offer; QA-034 copy.

## Acceptance Criteria
- [x] Identity error, profile loading and profile error show a close button that closes the paywall.
- [x] Offer state unchanged; existing paywall tests pass.
- [x] `resolvePaywallBody` unit-tested.

## Verification
`flutter analyze lib test`, `flutter test`.

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Ships with the next app build.
