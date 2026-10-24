# SPEC-0021: Profile Default Base Asset USD

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-030: a new profile has USD as its base asset from the start; the client does not patch it.

## Current Behavior
`handle_auth_user_created` and `api_ensure_profile` insert profiles with `base_asset_id = null`;
`EnsureProfileReadyUseCase` then writes USD with an extra request on first launch.

## Desired Behavior
- `profiles.base_asset_id` defaults to `public.default_base_asset_id()` (active fiat USD), so every
  insert path gets USD; existing nulls are backfilled.
- `EnsureProfileReadyUseCase` is removed; `ProfileCubit` loads the profile with `GetProfileUseCase`.
  Older app builds keep working (their USD write becomes a no-op).

## Out Of Scope
The duplicate USD lookup inside `api_apply_revenuecat_event` (base reset on Pro expiry).

## Acceptance Criteria
- [x] `/me` for a new user returns base asset USD (`auth_profile.test.ts`).
- [x] Client analyze/tests green.

## Verification
`qa/run.sh qa/api/auth_profile.test.ts`, `flutter analyze lib test`, `flutter test`.

## Documentation Updates
`docs/contracts/data-contract.md`, `docs/qa/findings.md`.

## Rollout Notes
`supabase db push`; client change ships with the next build.
