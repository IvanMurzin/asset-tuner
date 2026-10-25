# SPEC-0038: Pro Base Currency And History Layout

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-021 for real and QA-043: after buying Pro from the base-currency picker the requested
currency is applied, and a very long amount does not break the history row.

## Current Behavior
- `EntitlementsEntity.anyBaseCurrency` is `fiatLimit == null`, but `/me` returns
  `fiat_limit = 100` for Pro (`plan_limits`), so `_unlockAndApply` returns early and a Pro user
  tapping a "locked" currency gets the paywall again. The page test used `fiatLimit: null` for Pro,
  which never happens on prod.
- `DSHistoryEntryCard` puts an unconstrained trailing amount next to an `Expanded` column, so a
  24-digit amount squeezes the date and "Implied change" to one letter per line.

## Desired Behavior
- `anyBaseCurrency` is `plan == Plan.pro || fiatLimit == null`.
- The page test fixture mirrors `/me` (Pro 100, Free 5).
- The trailing column of `DSHistoryEntryCard` is `Flexible`.

## Acceptance Criteria
- [x] Entitlements test; the QA-021 page test fails on the old getter and passes on the new one.
- [x] History card test at 360 px: the label keeps a usable width (fails on the old layout).
- [x] `flutter analyze lib test` and `flutter test` pass.

## Verification
`flutter analyze lib test`, `flutter test`; emulator E10 and the large-amount history row.

## Documentation Updates
`docs/qa/findings.md` (QA-021, QA-043).

## Rollout Notes
Ships with the next app build.
