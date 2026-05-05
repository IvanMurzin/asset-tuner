# Asset Tuner Flutter Client

These rules apply to `client/`.

## Commands
Run from `client/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format .
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
```

## Architecture
The client uses layered architecture under `lib/`.

Dependency direction:

```text
presentation -> domain <- data
presentation -> core_ui
presentation -> core
data -> core
```

Layer purposes:
- `lib/core/` - infrastructure: DI, routing, config, Supabase wrapper, RevenueCat, Firebase, local storage, localization state, logging, shared types/utilities.
- `lib/core_ui/` - design system: theme, tokens, formatting helpers, DS components, preview page.
- `lib/domain/` - pure entities, repository interfaces, and use cases.
- `lib/data/` - DTOs, mappers, data sources, repository implementations.
- `lib/presentation/` - pages, widgets, Cubits, states.
- `lib/l10n/` - ARB localization sources and generated localizations.

Full technical reference: `docs/tech/client-architecture.md`.

## Feature Layout
Use feature folders inside each layer:

```text
domain/<feature>/{entity,repository,usecase}
data/<feature>/{dto,mapper,repository,data_source}
presentation/<feature>/{page,widget,bloc}
```

Do not create root-level generic feature folders such as `screens`, `models`, or `repositories`.

## Naming
- Files: `snake_case.dart`.
- Domain entities: `*_entity.dart`, `*Entity`, Freezed without JSON.
- Repository interfaces: `i_*_repository.dart`, `I*Repository`, `abstract interface class`.
- Use cases: `*_usecase.dart`, `*UseCase`, one public `call(...)` method.
- DTOs: `*_dto.dart` or `*_request_dto.dart`, `*Dto`, Freezed with JSON.
- Pages: `*_page.dart`, `*Page`.
- DS components: `ds_*.dart`, `DS*`.

## Hard Rules
- Do not edit generated files manually: `*.freezed.dart`, `*.g.dart`, `lib/core/di/injectable.config.dart`, generated localization Dart files.
- `presentation` must not import `data`.
- `domain` must not import Flutter, DTOs, Supabase, routing, DI, logging, or UI.
- `data` must not import `presentation` or `core_ui`.
- `core_ui` must not import feature layers.
- Prefer Cubit over Bloc unless the spec justifies event-driven Bloc.
- Prefer DS components over raw Material widgets for product UI.
- No `print()`; use `core/logger`.
- Do not add dependencies unless the active spec requires them.
- Keep user-visible strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ru.arb`.
- Keep Dart line length at 100.

## Code Generation
Run after Freezed, JSON, injectable, or localization changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing Expectations
- Run `flutter analyze` for any client-impacting change.
- Run targeted `flutter test` commands for changed behavior.
- Use fake repositories/data sources in tests. Do not mock Supabase from presentation tests.

## Spec Workflow
All non-trivial bugs, improvements, and features are implemented through `docs/specs/README.md`.
