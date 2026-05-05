# Presentation layer rules (UI, pages/widgets, state via Cubit/Bloc)

Applies to `lib/presentation/**`.

## Purpose
`lib/presentation` contains UI only:
- Pages (screens)
- UI widgets specific to pages/features
- State management (Cubit preferred, Bloc allowed when justified)
No data layer access directly; use domain contracts/use cases.

## Allowed dependencies
- Allowed:
  - `lib/domain/**`
  - `lib/core/**`
  - `lib/core_ui/**`
- Forbidden:
  - `lib/data/**` (no exceptions)
  - Any DTO imports
  - Any direct API/storage usage (must go through domain/repo contracts via DI)

## Feature structure (mandatory)
Inside presentation, everything is feature-scoped:
- `lib/presentation/<feature>/page/`
- `lib/presentation/<feature>/widget/`
- `lib/presentation/<feature>/bloc/` (folder name is always `bloc`, even if using cubit)

Do not create cross-feature folders like `screens/`, `ui/`, `components/` at the root of presentation.

## Pages (mandatory conventions)
- Location: `lib/presentation/<feature>/page/`
- File name: `*_page.dart`
- Type name: `*Page`
- Pages should be composition roots for that screen:
  - Wire up Cubit/Bloc providers
  - Compose page-specific widgets
  - Use DS components (core_ui) by default

## Widgets (mandatory conventions)
- Location: `lib/presentation/<feature>/widget/`
- Widgets are page-scoped and named accordingly:
  - Example: `profile_app_bar.dart` -> `ProfileAppBar`
- No widget-functions. Widgets must be classes in their own files.
- Prefer DS components and DS styling utilities; do not re-invent base controls.

## State management (mandatory conventions)
- Folder: `lib/presentation/<feature>/bloc/`
- Prefer Cubit:
  - Use Bloc only when there is a strong reason (complex event-driven flows).
- Naming:
  - Cubit file: `*_cubit.dart` -> `*Cubit`
  - Bloc file (if used): `*_bloc.dart` -> `*Bloc`
- State:
  - State file: `*_state.dart` (separate file)
  - Use `freezed` for states
  - Freezed v3 style: declare as `abstract class` or `sealed class` (not a concrete class).
  - States must not have JSON
  - State is connected via `part`/`part of` to the Cubit/Bloc file.
    - Example: `profile_cubit.dart` has `part 'profile_state.dart';`
    - `profile_state.dart` has `part of 'profile_cubit.dart';`

## UI states (required)
For any screen with async work, implement explicit UI states:
- loading
- success/data
- empty (when relevant)
- error (safe error message, no sensitive details)

## Prohibited patterns
- No direct calls to data layer, DTOs, Dio, storage.
- No navigation logic scattered across widgets:
  - Navigation uses core routing patterns (go_router) and should be invoked cleanly from page/cubit.
- No ad-hoc logging; use core logger only (no print).

## Output quality
- Keep widgets small and single-purpose.
- Keep Cubits thin; orchestration belongs in domain use cases when needed.
- UI must be minimal but tidy; use DS components consistently.
