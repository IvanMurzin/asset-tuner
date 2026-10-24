# SPEC-0036: Copy Pass

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-042: copy and validation nits from the 2026-10-24 regression.

## Desired Behavior
- Account cards use an ICU plural (`subaccountsCount`): "1 subaccount", "3 позиции", "5 позиций".
- English no longer says "position" ("Each subaccount is converted"); Russian keeps "позиция" as
  its term for subaccounts.
- Russian cash description is "Наличные деньги" instead of "Наличные в наличии".
- Add subaccount and Rename use "Subaccount name" / "Название позиции" instead of "Account name".
- Renaming to an empty name shows "Name is required" in the sheet instead of closing silently.

## Out Of Scope
The remaining hardcoded fallback strings (QA-032 refactor); legal URL hosting.

## Acceptance Criteria
- [x] Plural test for en and ru.
- [x] `flutter analyze lib test` and `flutter test` pass.

## Verification
`flutter analyze lib test`, `flutter test`; emulator E15 and E21 at the next regression.

## Documentation Updates
`docs/qa/findings.md` (QA-042).

## Rollout Notes
Ships with the next app build.
