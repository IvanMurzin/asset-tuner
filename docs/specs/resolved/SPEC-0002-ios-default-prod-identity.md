# SPEC-0002: iOS Default Prod Identity

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** codex
- **Created:** 2026-05-11
- **Resolved:** 2026-05-11

## Goal
Make iOS builds without an explicit Flutter flavor use the production app identity instead of
falling back to Flutter/Xcode defaults such as Runner.

## User Or Product Impact
iOS builds launched from default Xcode or Flutter configurations should show the same app name,
bundle identifier, deep link scheme, and app icon as the production flavor.

## Current Behavior
`client/ios/Runner/Info.plist` reads `CFBundleDisplayName`, `CFBundleName`, bundle identifier, and
deep link scheme from build settings. The `Debug-prod`, `Profile-prod`, and `Release-prod`
xcconfigs include `Flavor-prod.xcconfig`, but the base `Debug`, `Profile`, and `Release`
xcconfigs do not. The iOS Xcode project also has no `dev` or `prod` shared schemes registered,
so Flutter rejects `--flavor dev` and `--flavor prod` for iOS.

## Desired Behavior
The base iOS `Debug`, `Profile`, and `Release` configurations should be equivalent to production
identity defaults. Explicit dev and prod flavor builds should be available through shared Xcode
schemes and should resolve to their flavor-specific bundle identifier, display name, deep link
scheme, and icon.

## Scope
iOS Flutter xcconfig identity defaults, Xcode build configurations, shared flavor schemes,
CocoaPods configuration mapping, and verification of the effective bundle identifiers.

## Out Of Scope
Android flavor behavior, signing assets, Apple Developer portal settings, app icons, generated
Flutter files, and runtime Dart config.

## Constraints
Do not add dependencies. Do not edit generated files. Keep explicit dev/prod flavor config behavior
unchanged.

## Implementation Notes
Include `Flavor-prod.xcconfig` from `Debug.xcconfig`, `Profile.xcconfig`, and `Release.xcconfig`.
Register `Debug/Profile/Release` variants for `dev` and `prod` in `Runner.xcodeproj`, add shared
`dev` and `prod` schemes, and map the new configurations in `Podfile`. Because explicit dev
configs include the base config first and then `Flavor-dev.xcconfig`, dev values remain the final
effective values.

## Acceptance Criteria
- [x] Base iOS Debug/Profile/Release configs define `DISPLAY_NAME = Asset Tuner`.
- [x] Base iOS Debug/Profile/Release configs define `PRODUCT_BUNDLE_IDENTIFIER = developer.ivanmurzin.assettuner`.
- [x] Base iOS Debug/Profile/Release configs define `DEEP_LINK_SCHEME = assettuner`.
- [x] Explicit dev configs still resolve to `developer.ivanmurzin.assettuner.dev` and `Asset Tuner (dev)`.
- [x] `flutter build ios --config-only --flavor dev` no longer fails due to missing iOS schemes.
- [x] `flutter build ios --config-only --flavor prod` resolves to the production bundle id.
- [x] `flutter build ios --config-only` without flavor resolves to the production bundle id.
- [x] `Info.plist` continues to read app name and bundle id from build settings.

## Verification
- `cd client && xcodebuild -project ios/Runner.xcodeproj -scheme Runner -configuration Debug -showBuildSettings`
- `cd client && xcodebuild -project ios/Runner.xcodeproj -scheme dev -configuration Debug-dev -showBuildSettings`
- `cd client && xcodebuild -project ios/Runner.xcodeproj -scheme prod -configuration Debug-prod -showBuildSettings`
- `cd client && xcodebuild -project ios/Runner.xcodeproj -scheme Runner -configuration Release -showBuildSettings`
- `cd client && flutter build ios --config-only --flavor dev --dart-define-from-file=../.config.dev.json`
- `cd client && flutter build ios --config-only --flavor prod --dart-define-from-file=../.config.prod.json`
- `cd client && flutter build ios --config-only --dart-define-from-file=../.config.prod.json`

## Documentation Updates
None.

## Rollout Notes
None.
