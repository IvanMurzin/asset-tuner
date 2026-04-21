# Asset Tuner — Dependencies

**Last updated:** 2026-04-21

## Policy
- Prefer the existing template stack first (see `client/AGENTS.md`).
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
- `purchases_flutter`
- `purchases_ui_flutter`

## Client (accepted decisions)
- Supabase client: `supabase_flutter` (Auth, DB reads, Edge Function calls)
- Localization runtime: `flutter_localizations` (+ `intl` for formatting and generated l10n as needed)
- Payments: RevenueCat (`purchases_flutter`, `purchases_ui_flutter`) over App Store / Google Play
- Crash reporting + analytics: **not in MVP** (next iteration)

## Backend (Supabase)
- Supabase Auth
- Supabase Postgres + RLS
- Supabase Edge Functions (Deno)
- Supabase cron/scheduled triggers
