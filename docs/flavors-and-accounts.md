# Flavors, Bundle IDs, And Accounts

## Bundle IDs
| Flavor | Android applicationId | iOS bundle identifier | Deep link scheme | Release signing |
|---|---|---|---|---|
| `dev` | `developer.ivanmurzin.assettuner.dev` | `developer.ivanmurzin.assettuner.dev` | `assettunerdev` | debug keystore |
| `prod` | `developer.ivanmurzin.assettuner` | `developer.ivanmurzin.assettuner` | `assettuner` | release keystore from `client/android/key.properties` |

Both app variants can be installed on one device because their bundle IDs differ.

## Current Account Setup
- Supabase: the project referenced by `SUPABASE_URL` in `.config.prod.json` is production.
- RevenueCat: keys in `.config.prod.json` point to the production project/app setup.
- Apple Developer: `developer.ivanmurzin.assettuner` is production.
- Google Play Console: `developer.ivanmurzin.assettuner` is production.

At the time this document was written, dev and prod config files may still point to the same Supabase/RevenueCat resources. That is acceptable for local development but not ideal for isolated testing.

## Recommended Dev Isolation
For a fully isolated dev environment:

1. Create a separate Supabase project, for example `asset_tuner_dev`.
2. Put its URL and anon key into `.config.dev.json`.
3. Push migrations and deploy functions to the dev project.
4. Create separate RevenueCat dev app/project resources for `developer.ivanmurzin.assettuner.dev`.
5. Keep `ANALYTICS_ENABLED=false` in `.config.dev.json` unless a separate dev analytics stream exists.

## Build Targets
| Artifact | Destination |
|---|---|
| `prod` Android App Bundle | Google Play Console. |
| `prod` APK | Manual testing or release diagnostics. |
| `prod` iOS build | App Store Connect / TestFlight. |
| `dev` APK | Manual distribution. |
| `dev` iOS build | Local device or TestFlight only if a dev App Store Connect entry exists. |

## Xcode Flavor Setup
In `client/ios/Runner.xcworkspace`:

1. Duplicate `Debug`, `Release`, and `Profile` configurations into `Debug-dev`, `Release-dev`, `Profile-dev`, `Debug-prod`, `Release-prod`, and `Profile-prod`.
2. Bind them to the matching Flutter xcconfig files.
3. Create shared `dev` and `prod` schemes.
4. Assign the matching build configuration for Run/Test/Profile/Analyze/Archive.

Run commands:

```bash
cd client
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
```

## CI Secrets
For `.github/workflows/client_build.yml`, use:

| Secret | Purpose |
|---|---|
| `CONFIG_DEV_JSON` | Full `.config.dev.json` content. |
| `CONFIG_PROD_JSON` | Full `.config.prod.json` content. |
| `RELEASE_KEYSTORE_BASE64` | Base64-encoded Android release keystore. |
| `RELEASE_KEY_ALIAS` | Android key alias. |
| `RELEASE_KEY_PASSWORD` | Android key password. |
| `RELEASE_STORE_PASSWORD` | Android keystore password. |

## Firebase
Firebase is configured for the production flavor.

| Platform | Path | Bundle/package |
|---|---|---|
| Android prod | `client/android/app/src/prod/google-services.json` | `developer.ivanmurzin.assettuner` |
| iOS prod | `client/ios/Runner/GoogleService-Info.plist` | `developer.ivanmurzin.assettuner` |

Firebase project: `assettuner-8dc26`.

Crashlytics is active only in release mode. Analytics is active only when `AppConfig.analyticsActive` is true.

DebugView command:

```bash
adb shell setprop debug.firebase.analytics.app developer.ivanmurzin.assettuner
flutter run --flavor prod --release --dart-define-from-file=../.config.prod.json
```

Reset DebugView:

```bash
adb shell setprop debug.firebase.analytics.app .none.
```
