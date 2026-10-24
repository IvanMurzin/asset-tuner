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
- `http` (already resolved through `supabase_flutter`) only to recognize `ClientException` as a
  network failure.
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

## Android Toolchain
- Gradle 8.14.3 (AGP 8.11.1, Kotlin 2.2.20) runs on JDK 21; it does not run on Java 25+.
- `client/android/gradle/gradle-daemon-jvm.properties` (`toolchainVersion=21`) makes the Gradle
  daemon use an installed JDK 21 even when `JAVA_HOME` points elsewhere.
- `.sdkmanrc` (`java=21.0.9-tem`) pins the shell JDK for SDKMAN users (`sdk env`).
- Flutter builds use `flutter config --jdk-dir <JDK 21>`.
- Upgrading to Gradle 9.1+ with a matching AGP is a post-release task.
