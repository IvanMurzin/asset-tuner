# SPEC-0017: Recognize Network Errors And Timeouts

- **Type:** bug
- **Status:** Resolved
- **Priority:** P2
- **Owner:** claude
- **Created:** 2026-10-04
- **Resolved:** 2026-10-04

## Goal
Close QA-013: offline and transport failures are reported as "no connection", and API calls do not
hang forever.

## Current Behavior
`SupabaseFailureMapper` recognizes only `SocketException`. Offline requests usually fail with
`http.ClientException` (functions client), `AuthRetryableFetchException` without a status (gotrue),
`HandshakeException` or `TimeoutException`; they map to `unknown` and show an English fallback.
The `network` code has no translation either. Edge Function calls have no timeout.

## Desired Behavior
- One predicate in `SupabaseFailureMapper` classifies transport failures (no HTTP answer) as
  `network`: `SocketException`, `HandshakeException`, `TimeoutException`, `ClientException`,
  `AuthRetryableFetchException` without a status code (with a 5xx status it stays a server error).
- `network` is translated (EN/RU) as "No internet connection".
- `SupabaseEdgeFunctions.invokeApi` (the single entry point for API calls) times out after 20 s.

## Scope
`supabase_failure_mapper.dart`, `supabase_edge_functions.dart`, the two error-localization maps,
`pubspec.yaml` (declare `http`, already resolved transitively at 1.6.0 via supabase; needed to
match `ClientException`), tests.

## Out Of Scope
Auto-reload after reconnecting (needs a connectivity dependency); QA-032 refactor.

## Acceptance Criteria
- [x] Each transport exception maps to `network` with the localized message; a 5xx
  `AuthRetryableFetchException` does not.
- [x] A hanging function call fails with `network` after the timeout.

## Verification
`flutter analyze lib test`, `flutter test`; emulator E12 at the next regression.

## Documentation Updates
`docs/qa/findings.md`, `docs/tech/dependencies.md` (direct `http`).

## Rollout Notes
Ships with the next app build.
