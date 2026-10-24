# SPEC-0034: Auth And Client Hardening

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-011, QA-012, QA-015, QA-009 and QA-040 with small, low-risk fixes before release.

## Desired Behavior
- **QA-011:** the dev flavor uses the `assettuner-dev` scheme (Android manifest placeholder, iOS
  `Flavor-dev.xcconfig`, `.config.dev.json` and its example). Supabase Auth lists both
  `assettuner://login-callback/` and `assettuner-dev://login-callback/`.
- **QA-012:** `getAvailableProviders` offers Apple on iOS only.
- **QA-015:** the decimal field asks for a signed numeric keyboard.
- **QA-009:** `SupabaseErrorTranslator._translations` starts as the English map instead of `late`.
- **QA-040:** the assets data source awaits both kind requests with `Future.wait`.

## Out Of Scope
Native Google Sign-In; enabling Apple on Android.

## Acceptance Criteria
- [x] Repository test: no Apple on Android, Apple on iOS.
- [x] `flutter analyze lib test` and `flutter test` pass.
- [x] Prod Supabase Auth `uri_allow_list` contains both callbacks (set 2026-10-25).

## Verification
- `flutter analyze lib test`
- `flutter test`
- Device D2 (both flavors installed) and X1.

## Documentation Updates
`docs/flavors-and-accounts.md`, `docs/qa/findings.md`.

## Rollout Notes
Dev builds need a fresh install to pick up the new scheme. The Supabase redirect list was updated
on prod through the Management API.
