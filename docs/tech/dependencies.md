# Asset Tuner — Dependencies

**Last updated:** 2026-02-10

## Policy
- Prefer the existing template stack first (see `/Users/ivanmurzin/Projects/pets/asset_tuner/client/AGENTS.md`).
- Any new dependency or key decision requires an ADR in `docs/adr/`.

## Client (current, from `client/pubspec.yaml`)
- Flutter SDK
- `flutter_bloc` (Cubit preferred)
- `go_router`
- `get_it` + `injectable`
- `freezed_annotation` + codegen (`freezed`, `build_runner`)
- `json_annotation` + codegen (`json_serializable`)
- `logger`
- `shared_preferences`
- `decimal` (high-precision numeric arithmetic for money/crypto)

## Client (accepted decisions; may be added when implemented)
- Supabase client: `supabase_flutter` (Auth, DB reads, Edge Function calls)
- Localization runtime: `flutter_localizations` (+ `intl` for formatting and generated l10n as needed)
- Payments: TBD (likely `in_app_purchase`; ADR required before adding)
- Crash reporting + analytics: **not in MVP** (next iteration)

## Backend (Supabase)
- Supabase Auth
- Supabase Postgres + RLS
- Supabase Edge Functions (Deno)
- Supabase cron/scheduled triggers
