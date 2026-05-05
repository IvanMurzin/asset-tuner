# Operations

## Configuration Files
Runtime config is passed with Flutter `--dart-define-from-file`:

- `.config.dev.json`
- `.config.prod.json`

These files are gitignored. Templates live at the repository root as `*.example` files when present.

## Client Run Commands
Run from `client/`:

```bash
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build appbundle --flavor prod --release --dart-define-from-file=../.config.prod.json
```

## Backend Secrets
Production backend requires:

- `SUPABASE_URL`
- `OPENEXCHANGERATES_APP_ID`
- `SCHEDULER_SECRET`
- `REVENUECAT_WEBHOOK_SECRET`
- `REVENUECAT_API_KEY`

Optional:

- `COINGECKO_API_KEY`
- `REVENUECAT_PRO_ENTITLEMENT`
- `REVENUECAT_PRO_ENTITLEMENTS`
- `SUPABASE_SERVICE_ROLE_KEY` for local function serving.

## Backend Deploy
Run from repository root:

```bash
./backend/scripts/deploy_supabase.sh
```

The script links the project, pushes migrations, applies secrets, deploys functions, and can trigger an initial rates sync depending on environment configuration.

## Scheduled Jobs
Configure an hourly scheduler for `rates_sync` and pass:

```text
x-scheduler-secret: <SCHEDULER_SECRET>
```

Use `backend/scripts/setup_rates_sync_cron.sh` when available.

## RevenueCat
Set webhook URL:

```text
https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook
```

Set header:

```text
Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>
```

## Firebase
Firebase is configured for the production flavor.

- Android prod config: `client/android/app/src/prod/google-services.json`
- iOS prod config: `client/ios/Runner/GoogleService-Info.plist`
- Firebase project: `assettuner-8dc26`

Firebase initialization is gated by `AppConfig.firebaseEnabled`.
Analytics is active only when Firebase is enabled, analytics is enabled, and the app is running in release mode.

## Release Signing
- Dev Android release uses the debug keystore.
- Prod Android release requires `client/android/key.properties`.
- iOS flavor scheme setup is documented in `docs/flavors-and-accounts.md`.
