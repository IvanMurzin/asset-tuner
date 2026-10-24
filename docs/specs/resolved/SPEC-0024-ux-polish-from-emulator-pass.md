# SPEC-0024: UX Polish From Emulator Pass

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-033: the nine UX and accessibility items from the 2026-09-24 emulator pass.

## Desired Behavior
1. The paywall close button has a screen-reader label ("Close").
2. Sign up: an empty Confirm password shows "Confirm your password."; a different one stays
   "Passwords do not match."
3. Base currency: tapping anywhere on the current-currency card opens the picker
   (`DSBaseCurrencyValueCard.onTap`, `AssetCurrencyBadge.openPicker`).
4. / 8. An asset held in the base currency shows one amount, not the same value twice (subaccount
   rows, subaccount header, history, analytics breakdown).
5. The first history entry has no change lines instead of two `-` placeholders
   (`DSHistoryEntryCard` change lines are optional).
6. `DSEmptyCard` is one button: a tap anywhere and screen readers reach the action.
7. Error snackbars stay 6 s by default (others 4 s), set in `showDSSnackBar`.
9. `formatMoney` keeps at least two fraction digits ("250.50 USD"); asset quantities keep up to
   their requested precision.

## Out Of Scope
Copy changes beyond the two new strings; QA-032.

## Acceptance Criteria
- [x] Tests for formatting, sign-up validation, empty card tap, history card without change, close
  label.

## Verification
`flutter analyze lib test`, `flutter test`; emulator pass at the next regression.

## Documentation Updates
`docs/qa/findings.md`.

## Rollout Notes
Ships with the next app build.
