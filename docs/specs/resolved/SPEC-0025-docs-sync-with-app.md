# SPEC-0025: Docs Sync With App

- **Type:** docs
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-028: UX, architecture and backend docs describe the current app.

## Scope
- `docs/ux/screen-map.md`: public routes per `AppRoutes.publicLocations` (adds `/splash`, `/ds`
  needs auth), top-level pushed routes (`/paywall`, `/base-currency`, `/ds`).
- `docs/ux/user_journeys.md`: first launch (carousel → Sign up → first-auth paywall, USD default),
  Set balance (fixed date, no note), base currency Save step and post-purchase apply, custom paywall
  (RevenueCat UI only for Customer Center), pending payments.
- `docs/tech/client-architecture.md`: drop the non-existent `user` area and `data/account_asset/`;
  record the `ContactDeveloperPage` → repository deviation.
- `client/android/app/build.gradle.kts` comment: `google-services.json` lives in `android/app/`.
- `backend/README.md`: crypto seed is inline in `seed.sql`.

## Out Of Scope
Fixing the `ContactDeveloperPage` deviation in code.

## Acceptance Criteria
- [x] Every item listed in QA-028 is corrected.

## Verification
Manual review against `app_routes.dart`, `app_router.dart`, guards, and the listed files.

## Documentation Updates
The files above; `docs/qa/findings.md`.

## Rollout Notes
None.
