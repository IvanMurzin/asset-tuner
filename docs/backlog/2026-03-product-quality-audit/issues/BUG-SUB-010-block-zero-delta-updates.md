# BUG-SUB-010: Запретить нулевые изменения баланса (backend + client фильтр)

## Метаданные
- ID: `BUG-SUB-010`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
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
