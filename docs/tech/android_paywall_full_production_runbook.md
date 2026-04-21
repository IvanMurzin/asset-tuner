# Android Paywall Full - Production Readiness Runbook

**Last updated:** 2026-04-21
**Scope:** Android (`developer.ivanmurzin.assettuner`) + RevenueCat + Google Play + Supabase

## 1) Completed in codebase

- Android launch activity/package alignment fixed:
  - `client/android/app/src/main/kotlin/developer/ivanmurzin/assettuner/MainActivity.kt`
  - old template activity removed: `client/android/app/src/main/kotlin/com/example/template/MainActivity.kt`
- Paywall copy aligned to canonical free subaccounts limit `15`:
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - regenerated localizations:
    - `client/lib/l10n/app_localizations.dart`
    - `client/lib/l10n/app_localizations_en.dart`
    - `client/lib/l10n/app_localizations_ru.dart`
- Backend sync now calculates pro only by entitlement id `pro`:
  - `backend/supabase/functions/api/index.ts`
- Monetization docs with `TBD` replaced by actual RevenueCat flow:
  - `docs/tech/integrations.md`
  - `docs/tech/dependencies.md`
  - `docs/features/FTR-009-freemium-entitlements-and-paywall.md`

## 2) Mandatory manual console actions (RevenueCat + Google Play)

## 2.1 RevenueCat project setup
- Open RevenueCat dashboard and configure Android app with package:
  - `developer.ivanmurzin.assettuner`
- Upload Google Play service account JSON and wait for:
  - `Valid credentials`

## 2.2 Google Play subscription catalog
- In Google Play Console, create subscription:
  - `pro`
- Create and activate base plans:
  - `monthly-autorenewing`
  - `annual-autorenewing`
- Back in RevenueCat, import products from Play.

## 2.3 Entitlement and offering mapping
- Entitlement identifier:
  - `pro`
- Attach both products to entitlement `pro`.
- Offering:
  - identifier `pro`
  - set as current/fallback offering.
- Package mapping:
  - `$rc_monthly` -> `pro:monthly-autorenewing`
  - `$rc_annual` -> `pro:annual-autorenewing`

## 2.4 RevenueCat webhook
- Webhook URL:
  - `https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook`
- Header:
  - `Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>`
- Enable webhook events for both:
  - production
  - sandbox

## 2.5 Google RTDN
- In Google Play Monetization setup, connect Pub/Sub topic for RTDN.
- Send test notification.
- Verify in RevenueCat that RTDN "Last received" is updated.

## 3) Environment and deploy checklist

## 3.1 Client runtime key
- Update local production config:
  - `.config.prod.json`
- Set Android RevenueCat public SDK key to real production key:
  - `goog_...`
- Do not keep placeholder or `test_*` key in prod config.

## 3.2 Backend/Supabase keys
- Update local backend env:
  - `backend/.env`
- Ensure production secrets are set in Supabase project:
  - `REVENUECAT_API_KEY` must be RevenueCat server key used by `/api/revenuecat/refresh`
  - `REVENUECAT_WEBHOOK_SECRET` must match RevenueCat webhook header

## 3.3 Deploy
- Run:
```bash
./backend/scripts/deploy_supabase.sh
```
- Current status on 2026-04-21:
  - functions deployed (`api`, `rates_sync`, `revenuecat_webhook`)
  - optional remote seed step can fail if DB host DNS is unavailable (`psql`), rerun separately if needed

## 4) Verification checklist

## 4.1 Build and local quality gate
- Run:
```bash
cd client
flutter analyze
flutter test test/presentation/paywall/widget/paywall_visual_hierarchy_test.dart \
  test/presentation/session/bloc/session_cubit_test.dart \
  test/presentation/overview/widget/overview_summary_card_test.dart \
  test/presentation/overview/widget/tour_target_highlight_test.dart
flutter build appbundle --release --dart-define-from-file=../.config.prod.json
```

## 4.2 Android tester E2E
- Free user reaches gating and sees paywall.
- Purchase monthly/annual flips plan to `pro`, limits are lifted.
- Restore after reinstall/login returns user to `pro`.
- Cancel/expire returns user to free after sync/webhook.

## 4.3 Server-side validation
- `revenuecat_webhook` idempotency: duplicate `event.id` should be ignored.
- `/api/revenuecat/refresh` should update profile plan based on entitlement `pro`.
- Network failure on sync should be non-blocking on client and must not unlock access.
