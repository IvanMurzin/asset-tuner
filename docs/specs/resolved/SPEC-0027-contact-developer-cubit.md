# SPEC-0027: Contact Developer Cubit

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Remove the architecture deviation found in QA-028: `ContactDeveloperPage` called
`IProfileRepository` from the widget (and took an optional repository for tests).

## Desired Behavior
- `SendContactDeveloperMessageUseCase` (domain) builds the request; the sender-name rule (email local
  part, else user id) moves there.
- `ContactDeveloperCubit` owns validation, submission and the result (`idle`, `submitting`, `sent`,
  one-shot failure).
- The page renders and listens: `sent` → pop, failure → snackbar. No repository parameter; tests
  register the Cubit with a fake repository.

## Acceptance Criteria
- [x] Page tests pass without the repository parameter; use-case tests cover the sender name.

## Verification
`flutter analyze lib test`, `flutter test`.

## Documentation Updates
`docs/tech/client-architecture.md` (deviation note removed).

## Rollout Notes
Ships with the next app build.
