# BUG-CUR-003: Исправить формат строк в currency bottom sheet

## Метаданные
- ID: `BUG-CUR-003`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-003`, `FTR-005`, `SCR-008`, `SCR-012`

## Экран/модуль/слой
- Currency picker bottom sheet
- Слой: `core_ui`

## Проблема
### Текущее поведение
В строке валюты дублируется `slug/code` и нет полезной подписи курса к базовой валюте.

### Ожидаемое поведение
Формат строки: `CODE • Name` + подпись `1 CODE = X BASE`.

## Root-cause hypothesis
В [ds_currency_picker.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_currency_picker.dart) `tertiaryText` часто повторяет `primaryText` и не содержит rate-информацию.

## Предлагаемое решение
1. Перестроить модель отображения строки picker.
2. Добавить optional rate-caption на основе уже доступных rates/base currency.
3. Удалить дубли slug/code.

## Изменения API/контрактов/конфига
- API данных picker-опции расширяется полем `rateCaption`.

## Acceptance Criteria
1. Given любой список валют, when отображается строка, then нет дубликатов code.
2. Given rate доступен, when строка рендерится, then отображается `1 CODE = X BASE`.
3. Given rate недоступен, when строка рендерится, then отображается fallback без ломки layout.

## Тест-сценарии
### Manual
1. Base currency picker и add-subaccount picker.

### Auto
1. Widget tests formatting row text.

## Зависимости и блокеры
- Связано с `IMP-CUR-004`.

## Риски и anti-regression
- Не замедлить рендеринг списка из-за пересчета rates per-row.

## Ссылки на текущую реализацию
- [ds_currency_picker.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_currency_picker.dart)
