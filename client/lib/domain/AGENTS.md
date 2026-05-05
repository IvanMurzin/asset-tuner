# Domain layer rules (entities, repository contracts, use cases)

Applies to `lib/domain/**`.

## Purpose
`lib/domain` contains pure domain logic only:
- Entities (Freezed, no JSON)
- Repository contracts (interfaces only)
- Use cases (orchestration boundaries)
No infrastructure concerns. No Flutter. No DTO.

## Allowed dependencies
- Pure Dart only.
- Optional: shared core types (e.g., Result/Failure) if they are located in a types/contracts area.
- Forbidden imports:
  - `package:flutter/**` and any Flutter framework code
  - `lib/data/**`, `lib/presentation/**`, `lib/core_ui/**`
  - Core infrastructure: `lib/core/logger/**`, `lib/core/routing/**`, `lib/core/di/**`, `lib/core/api/**`, `lib/core/local_storage/**`, `lib/core/database/**`

If a domain type needs an error/result abstraction, depend on a small core type (e.g., `core/utils/result.dart`) rather than any infra service.

## Feature structure (mandatory)
Inside domain, everything is feature-scoped:
- `lib/domain/<feature>/entity/`
- `lib/domain/<feature>/repository/`
- `lib/domain/<feature>/usecase/`

Do not create cross-feature folders like `models/`, `repositories/`, `usecases/` at the root of domain.

## Entities (mandatory conventions)
- Location: `lib/domain/<feature>/entity/`
- File name: `*_entity.dart` (snake_case)
- Type name: `*Entity` (PascalCase)
- Must use Freezed:
  - Freezed v3 style: declare as `abstract class` or `sealed class` (not a concrete class).
  - Generate only what is needed.
  - No JSON (`fromJson/toJson`) in domain entities.

Do not put DTO fields/serialization details into entities. Entities represent business meaning, not API format.

## Repository contracts (mandatory conventions)
- Location: `lib/domain/<feature>/repository/`
- File name: `i_*_repository.dart`
- Type name: `I*Repository`
- Must be declared as `abstract interface class`.
- No implementations in domain.

Repository contract methods should:
- Use domain entities/value types.
- Use domain-level inputs (not DTO).
- Return domain-level results (e.g., `Future<Result<T>>`), if such a core type exists.

## Use cases (mandatory conventions)
- Location: `lib/domain/<feature>/usecase/`
- 1 use case = 1 file.
- File name: `*_usecase.dart`
- Type name: `*UseCase`
- Exactly one public method: `call(...)`
- Use cases are registered via DI with `@injectable` by default.
- Use cases are created only when they add value:
  - orchestration / business rule boundary
  - multi-step flow
  - reusable domain action
Do not create a use case for every trivial repository call.

## Prohibited patterns
- No `BuildContext`, widgets, UI types.
- No direct HTTP/database/storage code.
- No JSON serialization.
- No direct logging/routing/DI references.

## Output quality
Keep domain files minimal and clean. Favor explicit naming and stable contracts.
