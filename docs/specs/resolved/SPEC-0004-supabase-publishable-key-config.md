# SPEC-0004: Supabase Publishable Key Config

- **Type:** improvement
- **Status:** Resolved
- **Priority:** P1
- **Owner:** codex
- **Created:** 2026-07-02
- **Resolved:** 2026-07-02

## Goal
Rename the Flutter client Supabase public key configuration from the deprecated anon key naming to publishable key naming.

## User Or Product Impact
Developers use the current Supabase terminology in local config, CI-provided config JSON, and code. The client no longer triggers the `anonKey` deprecation warning during analysis.

## Current Behavior
`client/lib/core/config/app_config.dart` requires and reads `SUPABASE_ANON_KEY`, stores it as `supabaseAnonKey`, and `client/lib/core/supabase/supabase_initializer.dart` passes it to `Supabase.initialize(anonKey: ...)`. Config examples and flavor docs still mention anon key naming.

## Desired Behavior
The Flutter client requires `SUPABASE_PUBLISHABLE_KEY`, stores it as `supabasePublishableKey`, and passes it to `Supabase.initialize(publishableKey: ...)`. Config examples and local config files use `SUPABASE_PUBLISHABLE_KEY`.

## Scope
- Rename the client config key from `SUPABASE_ANON_KEY` to `SUPABASE_PUBLISHABLE_KEY`.
- Rename the matching `AppConfig` field.
- Use Supabase Flutter's `publishableKey` parameter.
- Update config examples and flavor setup docs.

## Out Of Scope
- Supabase project or dashboard changes.
- Backend secrets or service-role keys.
- Changing the actual Supabase key values.

## Constraints
- Do not add dependencies.
- Do not edit generated files.
- Preserve current RevenueCat config changes.

## Implementation Notes
Likely files:
- `client/lib/core/config/app_config.dart`
- `client/lib/core/supabase/supabase_initializer.dart`
- `.config.dev.json`
- `.config.prod.json`
- `.config.dev.json.example`
- `.config.prod.json.example`
- `docs/flavors-and-accounts.md`

## Acceptance Criteria
- [x] No client code reads `SUPABASE_ANON_KEY`.
- [x] `AppConfig` exposes `supabasePublishableKey`.
- [x] Supabase initialization uses `publishableKey`.
- [x] Config JSON files and examples use `SUPABASE_PUBLISHABLE_KEY`.
- [x] Flavor docs refer to a publishable key instead of anon key.

## Verification
- `cd client && dart format lib/core/config/app_config.dart lib/core/supabase/supabase_initializer.dart`
- `cd client && dart analyze lib/core/config/app_config.dart lib/core/supabase/supabase_initializer.dart`
- `rg -n "SUPABASE_ANON_KEY|supabaseAnonKey|anonKey" client/lib .config.dev.json .config.prod.json .config.dev.json.example .config.prod.json.example docs/flavors-and-accounts.md`

## Documentation Updates
Update flavor setup docs.

## Rollout Notes
Local and CI client config JSON must provide `SUPABASE_PUBLISHABLE_KEY`.
