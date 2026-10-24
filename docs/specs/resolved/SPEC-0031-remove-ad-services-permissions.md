# SPEC-0031: Remove Ad Services Permissions

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-036: the prod release manifest must not request Android Ad Services permissions the app
does not use, so the Play Data safety form can truthfully say no advertising ID is collected.

## Current Behavior
The merged prod manifest contained `ACCESS_ADSERVICES_AD_ID` and `ACCESS_ADSERVICES_ATTRIBUTION`,
pulled in by Firebase measurement. `com.google.android.gms.permission.AD_ID` was already removed.

## Desired Behavior
Both permissions are removed with `tools:node="remove"` in the app manifest.

## Scope
`client/android/app/src/main/AndroidManifest.xml`.

## Out Of Scope
Dart obfuscation: without a Crashlytics symbol upload step it makes Dart crash reports unreadable,
and the client holds no secrets. Revisit together with a symbol upload in CI.

## Acceptance Criteria
- [x] The merged `prodRelease` manifest has no `ADSERVICES` or `AD_ID` permission.

## Verification
`flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json`, then grep
the merged manifest.

## Documentation Updates
`docs/qa/findings.md` (QA-036).

## Rollout Notes
Ships with the next app build. Data safety: declare no advertising ID.
