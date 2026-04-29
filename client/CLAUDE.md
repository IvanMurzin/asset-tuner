# Asset Tuner — Flutter Client

## Architecture

Clean Architecture with strict one-way dependency: `data/` → `domain/` → `presentation/`.
Never import presentation into domain, or domain into data.

```
lib/
├── core/          # Infrastructure: DI, routing, Supabase, RevenueCat, localization, logger
├── core_ui/       # Design system: DS* components, theme, formatting
├── data/          # DTOs, data sources, repositories (impl), mappers
├── domain/        # Entities, use cases, repository interfaces
├── presentation/  # Cubits, states, pages, widgets
└── l10n/          # Generated ARB localization
```

Feature modules (apply in all layers): `account`, `asset`, `auth`, `balance`, `analytics`, `profile`, `rate`, `subaccount`.

---

## Patterns

### Cubit (state management)
```dart
// presentation/x/bloc/x_cubit.dart
@injectable
class XCubit extends Cubit<XState> {
  XCubit(this._useCase) : super(const XState());
  final XUseCase _useCase;
}

// presentation/x/bloc/x_state.dart
enum XStatus { initial, loading, ready, error }

@freezed
abstract class XState with _$XState {
  const XState._(); // required for getters
  const factory XState({
    @Default(XStatus.initial) XStatus status,
    // ... fields
    String? failureCode,
    String? failureMessage,
  }) = _XState;
}
```

### Repository interface
```dart
// domain/x/repository/i_x_repository.dart
abstract interface class IXRepository {
  Future<Result<XEntity>> fetchX();
}
```

### Repository implementation
```dart
// data/x/repository/x_repository.dart
@LazySingleton(as: IXRepository)
class XRepository implements IXRepository {
  XRepository(this._dataSource);
  final XDataSource _dataSource;

  @override
  Future<Result<XEntity>> fetchX() async {
    try {
      final dto = await _dataSource.fetchX();
      return Success(XMapper.toEntity(dto));
    } catch (error) {
      logger.e('XRepository.fetchX failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to load X'),
      );
    }
  }
}
```

### Data source (Supabase)
```dart
// data/x/data_source/supabase_x_data_source.dart
@lazySingleton
class SupabaseXDataSource {
  SupabaseXDataSource(this._edgeFunctions);
  final SupabaseEdgeFunctions _edgeFunctions;

  // TTL cache + in-flight deduplication pattern
  static const _cacheTtl = Duration(seconds: 60);
  List<XDto>? _cached;
  DateTime? _cachedAt;
  Future<List<XDto>>? _inFlight;
}
```

### Freezed entity
```dart
// domain/x/entity/x_entity.dart
@freezed
abstract class XEntity with _$XEntity {
  const XEntity._(); // add only when computed getters needed
  const factory XEntity({
    required String id,
    required String name,
  }) = _XEntity;

  // computed getter example
  String get displayName => name.toUpperCase();
}
```

### Freezed DTO (with JSON)
```dart
// data/x/dto/x_dto.dart
@freezed
abstract class XDto with _$XDto {
  const factory XDto({
    required String id,
    @JsonKey(name: 'display_name') required String name,
  }) = _XDto;

  factory XDto.fromJson(Map<String, dynamic> json) => _$XDtoFromJson(json);
}
```

### Mapper
```dart
// data/x/mapper/x_mapper.dart
abstract final class XMapper {
  static XEntity toEntity(XDto dto) => XEntity(id: dto.id, name: dto.name);
}
```

### Use case
```dart
// domain/x/use_case/get_x_use_case.dart
@injectable
class GetXUseCase {
  GetXUseCase(this._repository);
  final IXRepository _repository;

  Future<Result<XEntity>> call() => _repository.fetchX();
}
```

### DI module
```dart
// core/di/x_module.dart
@module
abstract class XModule {
  @lazySingleton
  XService get service => XService.instance;
}
```

---

## Result type

Never throw across layer boundaries. Always return `Result<T>`:
- `Success<T>(value)` — happy path
- `FailureResult(Failure(...))` — error path

```dart
final result = await useCase();
result.when(
  success: (value) => emit(state.copyWith(status: XStatus.ready, data: value)),
  failure: (failure) => emit(state.copyWith(
    status: XStatus.error,
    failureCode: failure.code,
    failureMessage: failure.message,
  )),
);
```

---

## DI rules

- Annotate cubits with `@injectable`
- Annotate singletons with `@lazySingleton` or `@singleton`
- Bind to interface: `@LazySingleton(as: IXRepository)`
- Use `@Named('key')` for multiple implementations of same type
- Never call `getIt<X>()` inside widgets — inject via constructor
- After adding any `@injectable` annotation: run codegen
- Generated file (never edit): `core/di/injectable.config.dart`

---

## Code generation

Run after any model or DI change:
```bash
dart run build_runner build --delete-conflicting-outputs
```

New model file checklist:
1. Add `part 'x.freezed.dart';` for `@freezed` classes
2. Add `part 'x.g.dart';` for `@JsonSerializable` / `fromJson`
3. Run codegen
4. Never manually edit `*.freezed.dart`, `*.g.dart`, `injectable.config.dart`

---

## Routing

- All routes: `go_router` with constants in `AppRoutes` — `core/routing/app_routes.dart`
- Use `pageBuilder` with `slideTransition(context, state, widget)` for every route
- Bottom nav: `StatefulShellRoute.indexedStack`
- Path params: `/accounts/:accountId` — extract via `state.pathParameters['accountId']`
- Navigate: `context.go(AppRoutes.x)` / `context.push(AppRoutes.x)`

---

## Localization

- Source files: `lib/l10n/app_en.arb` + `lib/l10n/app_ru.arb` — **always update both in sync**
- Access in widget: `final l10n = AppLocalizations.of(context)!;` then `l10n.keyName`
- Never hardcode user-visible strings in widgets or cubits
- Key format: camelCase, descriptive (`accountDeleteConfirmTitle`, not `deleteTitle`)

---

## Design system (`core_ui/`)

Always prefer `DS*` components over raw Material/Cupertino widgets.

| Component | Usage |
|-----------|-------|
| `DSButton` | All buttons — variants: `primary`, `secondary`, `danger`; `isLoading` flag |
| `DSAppBar` | All app bars |
| `DSTextField` / `DSPasswordField` | Text inputs |
| `DSCard` | Card containers |
| `DSDialog` | Modal dialogs |
| `DSEmptyState` | Empty list/state screens |
| `DSInlineError` | Inline error with retry action |
| `DSFullScreenLoader` | Full-screen loading overlay |
| `DSSnackbar` | Toast notifications |
| `DSShimmer` | Skeleton loading |
| `DSListRow` | List items |
| `DSSegmentedControl` | Tab-like selector |
| `DSSelectList` | Dropdown selection |
| `DSDecimalField` / `DSBalanceInput` | Numeric/money inputs |

Theme tokens: `context.dsColors`, `context.dsTypography` (never hardcode colors or text styles).

---

## Supabase integration

- Edge functions client: `SupabaseEdgeFunctions` — `core/supabase/`
- Invoke methods: `invokeDataList(route, query:, method:)`, `invokeData(...)`
- Route constants: `SupabaseApiRoutes` class
- Data sources own caching; repositories own error wrapping + mapping
- Auth state: via `AuthCubit` — `presentation/auth/bloc/auth_cubit.dart` (single source of truth: `authenticated` / `unauthenticated` / `initial`)
- Auth-driven navigation: handled centrally in `core/routing/app_router.dart` via `redirect` + `refreshListenable` — pages must NEVER manually `context.go(AppRoutes.signIn)` on auth state change
- Sign in / sign up / OTP success: do NOT navigate manually; `AuthCubit` resolves the new session, router redirect lands user on `/main`
- Sign out / delete account: just call `AuthCubit.signOut()` / `AuthCubit.deleteAccount()`; router handles the redirect to `/sign-in`

---

## RevenueCat / Paywall

- Packages: `purchases_flutter`, `purchases_ui_flutter`
- Entitlement checks: `core/revenuecat/`
- Paywall screen: use `purchases_ui_flutter` `RevenueCatUI.presentPaywall()`
- Never hardcode product IDs — read from `AppConfig`

---

## Dart conventions

- **Line length: 100** — enforced by `analysis_options.yaml` and auto-format hook
- **Strict mode**: `strict-casts`, `strict-inference`, `strict-raw-types` — no suppression
- **No `print()`** — use `logger.i/d/w/e` from `core/logger/app_logger.dart`
- **`const` everywhere** possible — constructors, widgets, values
- **Money/decimal**: always `Decimal` (package `decimal`), never `double`
- **Null safety**: no `!` on non-obvious nulls — use `?.`, `??`, or explicit checks
- Interface prefix: `I` — `IAssetRepository`, not `AssetRepositoryInterface`
- Abstract finals for namespace-only classes: `abstract final class AppRoutes { ... }`

---

## Testing

```bash
flutter test
```

- Unit tests: `test/` mirroring `lib/` structure, or next to source
- Test cubits via `bloc_test` patterns
- Use fake repository implementations — never mock Supabase directly
- Test use cases with fake repositories
- Widget tests: use `pumpWidget` with `MaterialApp` wrapper and real theme

---

## Backlog workflow

- Backlog: `docs/backlog/2026-03-product-quality-audit/`
- Index: `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- QA Registry: `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Command: `/iterate-backlog` — pick one task and deliver end-to-end
- Commit format: `backlog(<ISSUE-ID>): <short-summary>`
