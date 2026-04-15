# BUG-SUB-002: Убрать fiat/crypto radio на Add subaccount, перейти на unified picker

## Метаданные
- ID: `BUG-SUB-002`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-005`, `SCR-008`

## Экран/модуль/слой
- Экран: Add subaccount
- Слой: `presentation` + `core_ui`

## Проблема
### Текущее поведение
Пользователь сначала выбирает `fiat/crypto` через radio, затем отдельно открывает currency picker.

### Ожидаемое поведение
Единый сценарий выбора через badge/button -> bottom sheet с tabs внутри (для режима both).

## Root-cause hypothesis
В [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart) тип актива контролируется внешним `_kind`, а не режимом самого picker.

## Предлагаемое решение
1. Удалить отдельные radio-контролы.
2. Вызвать универсальный picker (`IMP-CUR-004`) в режиме `both`.
3. Поддержать default-tab на основе контекста.

## Изменения API/контрактов/конфига
- Нет внешних.

## Acceptance Criteria
1. Given пользователь добавляет субаккаунт, when открывает selector валют, then видит tabs fiat/crypto внутри bottom sheet.
2. Given выбран актив, when форма отправляется, then create_subaccount работает без регрессий.

## Тест-сценарии
### Manual
1. Выбор fiat и crypto в одном flow.

### Auto
1. Widget test: radio controls отсутствуют, selector работает.

## Зависимости и блокеры
- Зависит от `IMP-CUR-004`.

## Риски и anti-regression
- Не потерять paywall-логику для locked assets.

## Ссылки на текущую реализацию
- [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)

## Implementation note
- Реализация выполнена в рамках `IMP-DS-003`.
- На экране `Add subaccount` удалены `fiat/crypto` radio controls.
- Валюта теперь выбирается через `AssetCurrencyBadge` в suffix поля суммы.
- Bottom sheet поддерживает tabs `Fiat/Crypto` и selection в одном flow.
- Paywall-логика для locked assets сохранена через callback `onLocked`.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/asset/widget/asset_currency_badge_test.dart test/presentation/account/page/add_subaccount_page_test.dart test/presentation/balance/bloc/subaccount_create_cubit_test.dart` (pass)
