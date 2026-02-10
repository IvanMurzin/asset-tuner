# ADR-0001: Tech baseline

**Status:** Accepted  
**Date:** 2026-02-10

## Context
We are building a Flutter iOS/Android app with Supabase backend. The repository uses a strict layered architecture in `client/lib/` and has fixed default client patterns (go_router, get_it+injectable, flutter_bloc/Cubit, freezed).

The MVP requires:
- multi-device sync and strict per-user isolation,
- hourly server-cached FX + crypto rates,
- precision-safe money/crypto arithmetic,
- en+ru localization,
- dev/prod environments.

## Decision
### Client baseline
- Use the existing template stack:
  - Routing: `go_router`
  - DI: `get_it` + `injectable`
  - State: `flutter_bloc` (Cubit preferred)
  - Data models: Freezed (domain without JSON; DTO with JSON)
- Money arithmetic uses `decimal` (no `double` for amounts/rates).
- Localization supports `en` + `ru` via Flutter `gen-l10n` (ARB files).
- Observability: add structured app logging for important app and API events; no crash reporting/analytics in MVP.

### Backend baseline
- Supabase:
  - Auth: email OTP + Google + Apple
  - Postgres as system of record
  - RLS for all user-owned data
  - Scheduled job hourly for rates sync

### Environments/config
- Two environments in MVP: dev + prod.
- Client configuration uses `--dart-define-from-file` with local JSON files (`.config.dev.json`, `.config.prod.json`) that are not committed.

## Consequences
- We must implement a consistent error mapping and logging strategy in the client data layer.
- Edge Functions become the main surface for write workflows that need server-side validation/atomicity (covered by a separate ADR).
- Adding payments/crash/analytics is deferred; when introduced, they require ADRs and dependency review.

