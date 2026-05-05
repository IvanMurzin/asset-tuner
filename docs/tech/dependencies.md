# Dependencies

## Client
The current client stack is defined in `client/pubspec.yaml`.

Core dependencies:
- Flutter SDK and Dart SDK.
- `go_router` for routing.
- `flutter_bloc` for Cubit/Bloc state.
- `get_it` and `injectable` for DI.
- `freezed`, `json_serializable`, and `build_runner` for generated models and DI output.
- `supabase_flutter` for Auth and Edge Function calls.
- `decimal` for decimal-safe arithmetic.
- `purchases_flutter` and `purchases_ui_flutter` for RevenueCat.
- `firebase_core`, `firebase_analytics`, and `firebase_crashlytics` for prod observability.
- `shared_preferences` for local settings/cache.

## Backend
- Supabase CLI.
- Supabase Edge Runtime.
- Postgres SQL migrations.
- OpenExchangeRates.
- CoinGecko.
- RevenueCat REST API and webhooks.

## Dependency Policy
- Prefer existing dependencies.
- Add a dependency only when a spec requires it and the standard library/local stack is insufficient.
- Document new runtime dependencies in this file and update setup instructions when needed.
