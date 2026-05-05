# Core layer rules (DI, routing, logging, infra utilities)

Applies to `lib/core/**`.

## Purpose
`lib/core` is infrastructure only:
- DI configuration (get_it + injectable)
- Routing configuration (go_router)
- Logging (logger adapter)
- Shared utilities (extensions/helpers)
- Optional infra modules (api, local_storage, database) when needed

Core must not contain feature business logic or UI.

## Allowed dependencies
- Core should be as independent as possible.
- Forbidden:
  - `lib/presentation/**`
  - `lib/core_ui/**`
- Core may define small shared types used by domain (Result/Failure), but keep them in a types/contracts sub-area (not in infra modules).

## Directory conventions (recommended)
- `lib/core/di/` — get_it + injectable setup, generated config integration
- `lib/core/routing/` — go_router config, route names/paths, navigation helpers
- `lib/core/logger/` — single logging entry point used by all code
- `lib/core/utils/` — extensions and small pure helpers
Optional (only when needed):
- `lib/core/api/` — dio client, interceptors, error mapping
- `lib/core/local_storage/` — shared_preferences / secure_storage wrappers
- `lib/core/database/` — database config/wrappers

Do not create new core modules unless the spec requires them.

## DI rules (mandatory)
- DI uses `get_it` + `injectable` as default.
- Prefer injectable annotations over manual `getIt.register...`.
- Use cases should be registered via `@injectable` by default.
- Create `@module` only when needed (3rd-party types, factories, async/pre-resolve, cases where you cannot annotate the class directly).
- Keep DI wiring in `core/di` only.
- If generated DI files exist, never edit generated output manually.

## Routing rules (mandatory)
- Routing uses `go_router`.
- All route configuration lives in `core/routing`.
- Pages are referenced from routing, but routing should remain declarative and minimal.
- Avoid hardcoding navigation logic across the app; keep route names/paths centralized.

## Logging rules (mandatory)
- All logging goes through core logger adapter.
- No `print()` anywhere.
- Ensure logs are safe: do not log secrets/tokens/credentials/headers.

## Prohibited patterns
- No domain business rules here.
- No feature-specific implementation details (those live in domain/data/presentation).
- No DS components or UI composition here.

## Output quality
Core is a toolkit, not an app layer. Keep it minimal, stable, and reusable.
