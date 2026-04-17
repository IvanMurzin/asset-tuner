# BUG-SUB-009: На Set balance делать prefill текущего баланса и блокировать смену валюты

## Метаданные
- ID: `BUG-SUB-009`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-006`, `SCR-011`

## Экран/модуль/слой
- Экран: Set balance
- Слой: `presentation`

## Проблема
### Текущее поведение
Форма открытия balance-entry не префиллит текущую сумму; currency selector как отдельная концепция не отражен в disable-состоянии.

### Ожидаемое поведение
При открытии формы amount уже содержит текущее значение subaccount; валюта отображается readonly (без возможности изменения).

## Root-cause hypothesis
В [add_balance_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/add_balance_page.dart) контроллер суммы создается пустым в `initState`.

## Предлагаемое решение
1. Подставлять current balance при инициализации формы.
2. Перейти на `DSBalanceInput` с disabled currency badge.
3. Отразить это в copy экрана.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given у субаккаунта есть текущий баланс, when открывается Set balance, then поле amount предзаполнено.
2. Given форма открыта, when пользователь взаимодействует с валютой, then смена валюты недоступна.

## Тест-сценарии
### Manual
1. Открыть Set balance для subaccount с ненулевым балансом.

### Auto
1. Widget test на prefill amount controller.

## Зависимости и блокеры
- Связано с `IMP-DS-004`.

## Риски и anti-regression
- Корректно форматировать префилл с учетом locale/decimals.

## Ссылки на текущую реализацию
- [add_balance_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/add_balance_page.dart)

## Implementation note
- В [add_balance_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/add_balance_page.dart) поле amount теперь инициализируется из текущего баланса (`SubaccountInfoState.entries.first.snapshotAmount` с fallback на `subaccount.currentAmount`), поэтому форма Set balance открывается с prefill.
- Валюта остаётся readonly через `DSBalanceInput` + `AssetCurrencyBadge(enabled: false)`, поведение смены валюты не добавлялось.
- В [add_balance_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/balance/page/add_balance_page_test.dart) добавлен widget-тест на prefill (`123.45`) и скорректирован validation-тест (очистка поля перед submit).
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/balance/page/add_balance_page_test.dart` (pass)
