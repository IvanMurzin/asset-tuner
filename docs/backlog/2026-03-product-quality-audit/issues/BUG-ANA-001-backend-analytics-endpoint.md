# BUG-ANA-001: Вынести аналитику в backend endpoint(s), убрать fan-out с клиента

## Метаданные
- ID: `BUG-ANA-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
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
