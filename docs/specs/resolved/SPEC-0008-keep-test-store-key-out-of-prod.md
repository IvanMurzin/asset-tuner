# SPEC-0008: Keep Test Store Key Out Of Prod

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Address QA-004: the RevenueCat Test Store key must not ship inside prod builds, and the shared
dev = prod environment decision is documented.

## User Or Product Impact
Without the key in the prod binary, nobody can extract it and make free Test Store purchases that
the webhook turns into Pro. Owner/QA testing is unchanged.

## Current Behavior
- `.config.prod.json` (and `.config.prod.json.example`) define `REVENUECAT_API_KEY_TEST`.
- The flavor is resolved at runtime, so the constant is compiled into the prod `libapp.so`
  (confirmed in `app-prod-release.aab` from 2026-07-06).
- The webhook and refresh grant Pro regardless of `environment`/`store`.

## Desired Behavior
- `REVENUECAT_API_KEY_TEST` exists only in dev config; a prod release build does not contain it.
- `docs/flavors-and-accounts.md` states: one shared Supabase/RevenueCat project is a deliberate
  choice for now; Google Play sandbox (license testers only) is allowed to grant Pro; the Test Store
  key is dev-only.

## Scope
- Remove `REVENUECAT_API_KEY_TEST` from `.config.prod.json` (local, gitignored) and
  `.config.prod.json.example`.
- Update `docs/flavors-and-accounts.md`.
- Backlog item for a backend guard against `TEST_STORE` grants.

## Out Of Scope
- Backend filtering by `environment`/`store` (backlog).
- Splitting dev and prod projects.
- Rotating the Test Store key in the RevenueCat dashboard (owner action, see Rollout Notes).

## Constraints
- Prod flavor already resolves `REVENUECAT_API_KEY_ANDROID`/`_IOS`; no client code change needed.

## Acceptance Criteria
- [x] A fresh `flutter build appbundle --flavor prod --release` does not contain the Test Store key.
- [x] Dev flavor still resolves the Test Store key from `.config.dev.json`.
- [x] Docs and backlog updated.

## Verification
- Build the prod AAB and search `libapp.so` for the key value.
- `flutter test` in `client/`.

## Documentation Updates
- `docs/flavors-and-accounts.md`, `docs/backlog.md`, `docs/qa/findings.md`.

## Rollout Notes
Every prod build made before this change contains the key. If any of them was uploaded to Google
Play (any track), rotate the Test Store key in RevenueCat and update `.config.dev.json`.
Remove `REVENUECAT_API_KEY_TEST` from the `CONFIG_PROD_JSON` CI secret if it is set there.
Build release artifacts from a clean tree: an incremental build packaged a stale `libapp.so` that
still had the key until `flutter clean`.
