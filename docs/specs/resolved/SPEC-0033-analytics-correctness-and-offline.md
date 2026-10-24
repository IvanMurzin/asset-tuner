# SPEC-0033: Analytics Correctness And Offline States

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-037, QA-038 and QA-039: Analytics never shows an endless skeleton or a false empty state,
one Retry recovers Main after an offline start, shares are right with negative balances, and large
amounts are displayed exactly.

## Current Behavior
- `MainShellPage._maybeFeedAnalytics` returns early on a profile error (skeleton forever) and feeds
  `[]` when accounts are not ready ("No analytics yet" for a user with data).
- Main's profile error Retry reloads only the profile; accounts then need a second Retry.
- Breakdown shares divide by the signed total: with a debt they add up to 200%.
- `DSFormatters.formatDecimalFromDecimal` converts to `double`.

## Desired Behavior
- `AnalyticsCubit.onSourceFailed` shows an error with Retry when the profile or accounts failed,
  unless analytics data is already on screen. Analytics is fed only when accounts are ready.
- Main's profile error Retry reloads profile, accounts and assets together.
- Shares are computed over positive values; negative balances get 0% and are left out of the pie.
- Decimal formatting is exact, with locale grouping, decimal separator and minus sign; rounding
  and trailing-zero rules are unchanged.

## Scope
`main_shell_page.dart`, `overview_page.dart`, `analytics_cubit.dart`, `analytics_page.dart`,
`ds_formatters.dart`, tests.

## Out Of Scope
Auto-retry on reconnect; limiting input decimals per asset.

## Acceptance Criteria
- [x] Cubit tests for negative shares and source failures.
- [x] Formatter tests for a 24-digit amount, negatives, rounding and the ru locale.
- [x] `flutter analyze lib test` and `flutter test` pass.

## Verification
- `flutter analyze lib test`
- `flutter test`
- Emulator E11, E12 at the next regression.

## Documentation Updates
`docs/qa/findings.md` (QA-037, QA-038, QA-039).

## Rollout Notes
Ships with the next app build.
