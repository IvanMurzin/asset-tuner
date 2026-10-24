# SPEC-0032: Paywall Reasons And Copy

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-022 and QA-023 and the paywall part of QA-032: the paywall subtitle matches where it was
opened, a limit opens only the paywall, and purchase failures use app copy instead of store text.

## Current Behavior
- Profile → Upgrade and a locked currency on Add subaccount push `/paywall` without args; the
  router defaults to `baseCurrency` ("Unlock any base currency.").
- A limit failure opens the paywall and also shows an error snackbar ("Free plan position limit
  reached").
- A failed purchase shows `PlatformException.message` from the SDK, in English.

## Desired Behavior
- New `PaywallReason.upgrade` (Profile, and the router default) and
  `PaywallReason.subaccountCurrency` (locked currency on Add subaccount), each with its own en/ru
  copy and analytics reason name.
- The failure snackbar listeners on Add account and Add subaccount skip `limit_*` codes.
- English limit copy says "subaccount", not "position".
- Purchase failures map to `paywall_purchase` (or `network` for `networkError`) with no store
  message; the page shows `paywallPurchaseError`, `paywallRestoreError` or `errorNetwork`.

## Scope
Paywall args, cubit and page; Profile; Add account; Add subaccount; router default; ARB files;
`supabase_error_localization_en.dart`.

## Out Of Scope
The full error-codes → ARB refactor for the rest of QA-032.

## Acceptance Criteria
- [x] Cubit tests: store error has no store text; network error → `network`.
- [x] `flutter analyze lib test` and `flutter test test/presentation` pass.

## Verification
- `flutter analyze lib test`
- `flutter test test/presentation`
- Emulator E7, E9, E23, E24 at the next regression.

## Documentation Updates
`docs/qa/findings.md` (QA-022, QA-023, QA-032).

## Rollout Notes
Ships with the next app build. New analytics reason names: `upgrade`, `subaccount_currency`.
