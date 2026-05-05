# Data layer rules (DTO, mappers, repository implementations, integrations)

Applies to `lib/data/**`.

## Purpose
`lib/data` adapts external/internal data sources to the domain:
- DTOs (Freezed + JSON)
- Mappers (DTO <-> Entity)
- Repository implementations (implement domain contracts)
- Optional integrations (service/data_source) only when justified

Data must not leak DTOs into domain/presentation. Presentation consumes domain entities.

## Allowed dependencies
- May depend on:
  - `lib/domain/**` (contracts/entities)
  - `lib/core/**` (infra utilities: api client, storage, logger, etc.)
- Forbidden imports:
  - `lib/presentation/**`
  - `lib/core_ui/**`

## Feature structure (mandatory)
Inside data, everything is feature-scoped:
- `lib/data/<feature>/dto/`
- `lib/data/<feature>/mapper/`
- `lib/data/<feature>/repository/`
Optional (rare, only when justified):
- `lib/data/<feature>/service/`
- `lib/data/<feature>/data_source/`

Do not create cross-feature folders like `models/`, `network/`, `repositories/` at the root of data.

## DTO rules (mandatory)
- Location: `lib/data/<feature>/dto/`
- File naming:
  - General DTO: `*_dto.dart` -> `*Dto`
  - Request DTO: `*_request_dto.dart` -> `*RequestDto`
  - Response DTO: use `*_dto.dart` unless a separate response type is necessary.
- Must use Freezed + JSON:
  - Provide `fromJson/toJson` via `json_serializable`.
  - DTOs are allowed to match API formats (snake_case keys via annotations, etc.).
  - For JSON field renames, use `@JsonName("field_name")` on the field.

DTOs must never be used in domain or presentation.

## Mapper rules (mandatory)
- Location: `lib/data/<feature>/mapper/`
- One mapper per conceptual model (e.g., UserMapper).
- Declaration format: `abstract final class <Name>Mapper`
- Methods:
  - `static <Entity> toEntity(<Dto> dto)`
  - `static <Dto> toDto(<Entity> entity)`
Create only the directions needed (do not create unused methods).
Mappers must be pure and deterministic (no IO, no logging, no side effects).

## Repository implementation rules (mandatory)
- Location: `lib/data/<feature>/repository/`
- File name: `*_repository.dart` (no `i_` prefix)
- Type name: `*Repository`
- Must implement the domain interface from `lib/domain/<feature>/repository/i_*_repository.dart`.
- Must be registered via injectable annotations:
  - Example: `@lazySingleton(as: IAuthRepository)` on `AuthRepository`.
- Repository methods:
  - Perform IO (API/storage) via core infra modules.
  - Map DTO <-> Entity via mappers.
  - Convert transport/storage errors into domain-level failures (use shared error mapping conventions, if defined in core).
  - Must not return DTOs outward.

## service/ and data_source/ usage (rare)
- `service/`:
  - Only for special platform/integration cases (e.g., bluetooth, sensors).
  - Must have a clear, narrow responsibility.
- `data_source/`:
  - Only for complex multi-source scenarios where separating low-level source access is justified.
  - Default approach: API/local storage access is done inside repositories.
Do not create these folders unless the spec explicitly demands a complex integration.

## Prohibited patterns
- No UI code.
- No direct navigation.
- No exposing DTOs outside data layer.
- No ad-hoc dependency registration; use injectable.

## Output quality
Keep repositories thin:
- validation/orchestration belongs in domain use cases (when needed),
- mapping is in mappers,
- IO wiring is in repository/service/data_source.
