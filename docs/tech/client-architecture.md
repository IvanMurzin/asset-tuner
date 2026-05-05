# Flutter Client Architecture

The client uses layered architecture under `client/lib`.

## Dependency Direction
The domain layer is the center:

```text
presentation -> domain <- data
presentation -> core_ui
presentation -> core
data -> core
core_ui -> Flutter/material only, plus minimal pure core utilities when justified
core -> infrastructure and shared pure types
```

Forbidden:
- `presentation` must not import `data`.
- `domain` must not import Flutter, DTOs, repositories implementations, routing, DI, logging, Supabase, RevenueCat, or UI.
- `core_ui` must not import feature layers.
- `data` must not import `presentation` or `core_ui`.

## Layer Purposes
- `core/` - DI, routing, config, Supabase client wrapper, RevenueCat integration, Firebase, local storage, localization state, logging, shared types/utilities.
- `core_ui/` - design system components, theme tokens, formatting helpers, and preview page.
- `domain/` - entities, repository interfaces, and use cases.
- `data/` - DTOs, mappers, data sources, and repository implementations.
- `presentation/` - pages, widgets, Cubits, and states.
- `l10n/` - ARB files and generated localization output.

## Feature Layout
Feature modules are repeated per layer:

```text
domain/<feature>/{entity,repository,usecase}
data/<feature>/{dto,mapper,repository,data_source}
presentation/<feature>/{page,widget,bloc}
```

Full-stack features (have `domain/`, `data/`, and `presentation/` folders): `account`, `analytics`, `asset`, `auth`, `balance`, `profile`, `rate`, `subaccount`.

Presentation-only areas (UI-only, no `domain/` or `data/` layer; they compose other features' use cases): `home`, `onboarding`, `overview`, `paywall`, `settings`, `user`. Do not introduce a synthetic domain layer for these.

Shared cross-feature data helpers (for example `data/account_asset/`) are allowed when they only compose existing feature data sources; they must not introduce a new domain layer.

## Code Generation
Run codegen after changing Freezed models, JSON DTOs, injectable annotations, or localization:

```bash
cd client
dart run build_runner build --delete-conflicting-outputs
```

Never manually edit generated files.

## Localization
- Source files: `client/lib/l10n/app_en.arb` and `client/lib/l10n/app_ru.arb`.
- User-visible strings must not be hardcoded in widgets or Cubits.
- Keep English and Russian keys synchronized.
- Use descriptive camelCase keys.

## Design System
Use `DS*` components from `client/lib/core_ui/components` before raw Material widgets.

Common components include `DSButton`, `DSAppBar`, `DSCard`, `DSTextField`, `DSPasswordField`, `DSDecimalField`, `DSBalanceInput`, `DSDialog`, `DSInlineError`, `DSEmptyState`, `DSListRow`, `DSSegmentedControl`, `DSSelectList`, `DSSnackbar`, and `DSShimmer`.

Use `context.dsColors` and `context.dsTypography`; avoid hardcoded visual styling unless a spec explicitly requires a new DS token/component.

## State Management
- Prefer Cubit over Bloc.
- State files use Freezed and live beside the Cubit in `bloc/`.
- Screens with async data must represent loading, success, empty when relevant, and error states.
- Cubits should call domain use cases or domain repositories through DI; they should not call data sources directly.

## Routing
- `go_router` is configured in `client/lib/core/routing`.
- Routes are declared in `AppRoutes`.
- Auth/navigation redirects are centralized through route guards.
- All route pages use the shared transition helper.

## Error Handling
- Repository methods return domain-level `Result<T>` values.
- Transport and backend errors are mapped to `Failure`.
- Do not throw across layer boundaries unless the existing local API explicitly does so internally before mapping.

## Testing
- Run `flutter analyze` for client-impacting changes.
- Add targeted tests for shared logic, Cubits, mappers, routing, and DS components when behavior changes.
- Use fake repositories or fake data sources; do not mock Supabase directly from presentation tests.
