# SPEC-0003: RevenueCat Client Key Selection

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P1
- **Owner:** codex
- **Created:** 2026-07-02
- **Resolved:** 2026-07-02

## Goal
Make the Flutter client select RevenueCat public SDK keys from explicit dev/test and platform-specific config keys instead of the legacy generic `REVENUECAT_API_KEY`.

## User Or Product Impact
Developers can keep dev builds on a test RevenueCat key while production builds use the Android or iOS public SDK key that matches the target platform.

## Current Behavior
`client/lib/core/config/app_config.dart` still reads `REVENUECAT_API_KEY` as a generic fallback before trying `REVENUECAT_API_KEY_ANDROID`, `REVENUECAT_API_KEY_IOS`, or `REVENUECAT_API_KEY_TEST`. The example config files still document `REVENUECAT_API_KEY`.

## Desired Behavior
For the Flutter client:
- `FLAVOR=dev` uses `REVENUECAT_API_KEY_TEST`.
- Non-dev flavors use `REVENUECAT_API_KEY_ANDROID` on Android and `REVENUECAT_API_KEY_IOS` on iOS.
- `REVENUECAT_API_KEY` is not read by client app config and is removed from client config examples.

## Scope
- Update `AppConfig` RevenueCat key resolution.
- Update client config examples.
- Add focused tests for the key selection rules.

## Out Of Scope
- Backend RevenueCat server secret handling. Backend Edge Functions and deploy scripts may continue using their server-side `REVENUECAT_API_KEY`.
- RevenueCat dashboard, product, entitlement, or offering changes.
- Real secret values in local `.config.*.json` files.

## Constraints
- Do not add dependencies.
- Do not edit generated files.
- Keep backend server API key docs unchanged unless they describe client config.

## Implementation Notes
Likely files:
- `client/lib/core/config/app_config.dart`
- `.config.dev.json.example`
- `.config.prod.json.example`
- `client/test/core/config/app_config_test.dart`

## Acceptance Criteria
- [x] `AppConfig` no longer reads `REVENUECAT_API_KEY` from Dart defines.
- [x] Dev flavor resolves to `REVENUECAT_API_KEY_TEST` regardless of target platform.
- [x] Prod flavor resolves to Android key on Android and iOS key on iOS.
- [x] Unsupported non-dev platforms return no RevenueCat key instead of falling back to another platform.
- [x] Client config examples use `REVENUECAT_API_KEY_TEST`, `REVENUECAT_API_KEY_ANDROID`, and `REVENUECAT_API_KEY_IOS`.

## Verification
- `cd client && dart format lib/core/config/app_config.dart test/core/config/app_config_test.dart`
- `cd client && flutter test test/core/config/app_config_test.dart`
- `cd client && flutter analyze`

## Documentation Updates
Update client config examples. Product and backend docs do not need changes.

## Rollout Notes
Local and CI client configs must provide the new RevenueCat keys. Existing backend server secrets are unchanged.
