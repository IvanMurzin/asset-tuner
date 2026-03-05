# IMP-CUR-004: Универсальный currency picker с режимами `fiat|crypto|both`

## Метаданные
- ID: `IMP-CUR-004`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-003`, `FTR-005`, `SCR-008`, `SCR-012`

## Экран/модуль/слой
- Currency selector (shared)
- Слои: `core_ui`, `presentation`

## Проблема
### Текущее поведение
Выбор fiat/crypto логики разнесен по экранам (например, radio selector в add-subaccount) и не масштабируется.

### Ожидаемое поведение
Единый bottom sheet компонент с режимами:
- `fiatOnly`,
- `cryptoOnly`,
- `both` (с tabs),
с корректным preselect/search.

## Root-cause hypothesis
Текущий picker не поддерживает tabbed режимы и фильтрацию на уровне параметров.

## Предлагаемое решение
1. Добавить режимы в DS picker API.
2. В режиме `both` показывать tabs внутри sheet.
3. Перевести add-subaccount на новый picker и убрать отдельный fiat/crypto radio.

## Изменения API/контрактов/конфига
- Публичный API DS picker: `mode`, `initialTab`, `allowedKinds`.

## Acceptance Criteria
1. Given base currency screen, when picker открывается, then доступны только fiat и без tabs.
2. Given add subaccount, when picker в режиме both, then пользователь переключает tabs и выбирает актив.
3. Given cryptoOnly/fiatOnly режим, when открывается sheet, then недопустимые виды скрыты.

## Тест-сценарии
### Manual
1. Прогон режимов на разных экранах.

### Auto
1. Widget tests по всем режимам.

## Зависимости и блокеры
- Зависит от `IMP-DS-003`.

## Риски и anti-regression
- Сохранить совместимость со старым вызовом picker до полной миграции.

## Ссылки на текущую реализацию
- [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)
- [ds_currency_picker.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_currency_picker.dart)
