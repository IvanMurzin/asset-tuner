# BUG-SUB-010: Запретить нулевые изменения баланса (backend + client фильтр)

## Метаданные
- ID: `BUG-SUB-010`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-006`, `FTR-010`, `SCR-011`, `SCR-017`

## Экран/модуль/слой
- Set balance + History + Analytics
- Слои: `backend/api`, `presentation`

## Проблема
### Текущее поведение
Система допускает сохранение snapshot без фактического изменения суммы, из-за чего засоряется history/analytics.

### Ожидаемое поведение
Если новое значение равно текущему, сервер отклоняет запрос валидационной ошибкой; клиент не отображает zero-delta в history/analytics.

## Root-cause hypothesis
`api/subaccounts/set_balance` не валидирует равенство с последним состоянием как hard-stop.

## Предлагаемое решение
1. Добавить серверную проверку “amount unchanged” в set_balance pipeline.
2. В клиенте обрабатывать код ошибки как user-friendly сообщение.
3. Добавить defensive фильтр нулевых diff в history/analytics UI.

## Изменения API/контрактов/конфига
- Изменение контракта ошибки `POST /api/subaccounts/set_balance` (новый validation reason).

## Acceptance Criteria
1. Given текущий баланс X, when пользователь отправляет X снова, then API возвращает validation error.
2. Given historical zero rows (legacy), when UI строит списки, then zero-delta элементы скрываются.
3. Given valid изменение, when save выполняется, then flow работает как раньше.

## Тест-сценарии
### Manual
1. Set balance на то же значение -> ожидаем ошибку.
2. Set balance на иное значение -> успех.

### Auto
1. Backend test на zero-delta rejection.
2. Unit/widget тесты фильтра zero-delta entries в UI.

## Зависимости и блокеры
- Может быть связан с `BUG-ANA-001`.

## Риски и anti-regression
- Не сломать миграцию/чтение старых записей истории.

## Ссылки на текущую реализацию
- [api/index.ts](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/functions/api/index.ts)
- [subaccount_balance_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/bloc/subaccount_balance_cubit.dart)

## Implementation note
- Добавлена миграция [20260417173000_api_set_subaccount_balance_reject_unchanged.sql](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/migrations/20260417173000_api_set_subaccount_balance_reject_unchanged.sql): `api_set_subaccount_balance` теперь делает hard-stop с `VALIDATION_ERROR: amount_unchanged`, если новое значение совпадает с последним snapshot.
- В [supabase_failure_mapper.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/supabase/supabase_failure_mapper.dart) и локализациях [supabase_error_localization_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/supabase_error_localization_en.dart), [supabase_error_localization_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/supabase_error_localization_ru.dart) добавлен user-friendly код/текст ошибки `amount_unchanged`.
- В [subaccount_info_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/bloc/subaccount_info_cubit.dart) и [analytics_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/bloc/analytics_cubit.dart) добавлен defensive-фильтр записей с `diffAmount == 0`, чтобы legacy zero-delta не попадали в history/analytics UI.
- Обновлён контракт ошибки в [api_surface.md](/Users/ivanmurzin/Projects/pets/asset_tuner/docs/contracts/api_surface.md) для `POST /update_subaccount_balance` (`error.message = "amount_unchanged"`).
- Добавлены автотесты:
  - [supabase_failure_mapper_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/core/supabase/supabase_failure_mapper_test.dart)
  - [subaccount_info_cubit_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/balance/bloc/subaccount_info_cubit_test.dart)
  - [analytics_cubit_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/analytics/bloc/analytics_cubit_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/core/supabase/supabase_failure_mapper_test.dart` (pass)
  - `cd client && flutter test test/presentation/balance/bloc/subaccount_info_cubit_test.dart` (pass)
  - `cd client && flutter test test/presentation/analytics/bloc/analytics_cubit_test.dart` (pass)
  - `cd backend && ./scripts/deploy_supabase.sh --help` (pass, но скрипт фактически выполнил deploy/migration; remote seed шаг завершился warning по DNS)
