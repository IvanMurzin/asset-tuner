# IMP-DS-004: Добавить компонент `DSBalanceInput` (amount + currency badge)

## Метаданные
- ID: `IMP-DS-004`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-008`, `SCR-011`, `SCR-010`

## Экран/модуль/слой
- Формы баланса
- Слой: `core_ui` + `presentation`

## Проблема
### Текущее поведение
Amount input и selector валюты собраны разными элементами, визуально выглядят как несвязанные блоки.

### Ожидаемое поведение
Единый компонент `DSBalanceInput`: поле суммы + встроенный справа `DSCurrencyBadge`, стилистически цельный control.

## Root-cause hypothesis
Отсутствует composable DS-компонент для сценариев money+currency.

## Предлагаемое решение
1. Создать `DSBalanceInput` c вариантами:
   - currency selector enabled,
   - currency selector disabled (readonly).
2. Использовать в `Add subaccount` и `Set balance`.
3. Перенести валидационные состояния в этот компонент.

## Изменения API/контрактов/конфига
- Новый DS API компонента.

## Acceptance Criteria
1. Given экран создания/обновления баланса, when рендерится форма, then используется `DSBalanceInput`.
2. Given set-balance режим, when поле валюты disabled, then валюта отображается, но не редактируется.
3. Given error amount, when валидация не проходит, then error показывается inline в составе компонента.

## Тест-сценарии
### Manual
1. Проверка compose-UI в add-subaccount и set-balance.

### Auto
1. Widget tests для enabled/disabled/error состояний.

## Зависимости и блокеры
- Зависит от `IMP-DS-003`.

## Риски и anti-regression
- Не ухудшить доступность (tap targets, screen reader labels).

## Ссылки на текущую реализацию
- [ds_decimal_field.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_decimal_field.dart)
- [add_balance_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/add_balance_page.dart)
