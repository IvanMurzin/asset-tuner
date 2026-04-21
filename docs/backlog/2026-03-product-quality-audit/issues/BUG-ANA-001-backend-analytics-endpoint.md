# BUG-ANA-001: Вынести аналитику в backend endpoint(s), убрать fan-out с клиента

## Метаданные
- ID: `BUG-ANA-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-010`, `SCR-017`, `FR-080`, `FR-081`

## Экран/модуль/слой
- Экран: Analytics
- Слои: `backend edge/rpc`, `data`, `domain`, `presentation`

## Проблема
### Текущее поведение
`AnalyticsCubit` выполняет множество запросов (`accounts`, `subaccounts`, `history` по каждому subaccount), что дорого и хрупко при росте данных.

### Ожидаемое поведение
Analytics-tab получает агрегированные данные из отдельной backend ручки (или нескольких согласованных ручек), а клиент лишь отображает результат.

## Root-cause hypothesis
В [analytics_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/bloc/analytics_cubit.dart) реализован client-side fan-out с `Future.wait` на каждый account/subaccount.

## Предлагаемое решение
1. Добавить backend endpoint `api/analytics/summary` (edge -> rpc).
2. В endpoint вернуть:
   - breakdown,
   - balance snapshots feed,
   - `as_of`/meta.
3. Мигрировать data/domain слои клиента на новый контракт.

## Изменения API/контрактов/конфига
- Новый публичный API endpoint для аналитики.
- Обновление `docs/contracts/api_surface.md`.

## Acceptance Criteria
1. Given analytics screen, when данные загружаются, then используется только analytics endpoint(s), без fan-out history запросов.
2. Given изменение account/subaccount/balance, when refresh triggered, then analytics отражает новое состояние.
3. Given backend error, when endpoint недоступен, then клиент показывает retryable error.

## Тест-сценарии
### Manual
1. Сравнить значения старой/новой аналитики на одном наборе данных.

### Auto
1. Backend tests RPC/edge aggregation.
2. Client unit tests parsing analytics DTO.

## Зависимости и блокеры
- Блокирует `BUG-ANA-002`, частично `BUG-ANA-003`.

## Риски и anti-regression
- Согласовать decimal precision и исключение unpriced/zero-delta записей.

## Ссылки на текущую реализацию
- [analytics_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/bloc/analytics_cubit.dart)
- [api/index.ts](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/functions/api/index.ts)

## Implementation note
- Добавлен backend aggregation endpoint `GET /api/analytics/summary`: edge route в [index.ts](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/functions/api/index.ts) и SQL RPC [20260421183000_api_analytics_summary.sql](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/migrations/20260421183000_api_analytics_summary.sql), который возвращает `breakdown`, `updates` и `as_of` без client-side fan-out.
- В клиенте добавлен отдельный analytics data/domain pipeline:
  - [supabase_analytics_data_source.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/data/analytics/data_source/supabase_analytics_data_source.dart),
  - [analytics_repository.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/data/analytics/repository/analytics_repository.dart),
  - [analytics_summary_entity.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/domain/analytics/entity/analytics_summary_entity.dart),
  - [get_analytics_summary_usecase.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/domain/analytics/usecase/get_analytics_summary_usecase.dart).
- [analytics_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/bloc/analytics_cubit.dart) переведён с `subaccounts + current balances + history` fan-out на единый `GetAnalyticsSummaryUseCase`; retryable error flow сохранён через существующий `AnalyticsStatus.error`.
- Обновлён API контракт в [api_surface.md](/Users/ivanmurzin/Projects/pets/asset_tuner/docs/contracts/api_surface.md) и добавлен route-констант [supabase_constants.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/supabase/supabase_constants.dart).
- Обновлён unit test [analytics_cubit_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/analytics/bloc/analytics_cubit_test.dart) под новую архитектуру.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/analytics/bloc/analytics_cubit_test.dart` (pass)
  - `cd backend && deno check supabase/functions/api/index.ts` (not executed: environment limitation, `deno` отсутствует)
  - `cd backend && ./scripts/deploy_supabase.sh --help` (not executed: скрипт выполняет реальные remote deploy/migration steps и не является безопасной локальной проверкой)
