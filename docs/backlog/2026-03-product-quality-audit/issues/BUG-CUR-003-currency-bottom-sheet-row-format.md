# BUG-CUR-003: Исправить формат строк в currency bottom sheet

## Метаданные
- ID: `BUG-CUR-003`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-003`, `FTR-005`, `SCR-008`, `SCR-012`

## Экран/модуль/слой
- Currency picker bottom sheet
- Слой: `presentation`

## Проблема
### Текущее поведение
В строке валюты дублируется `slug/code` и нет полезной подписи курса к базовой валюте.

### Ожидаемое поведение
Формат строки: `CODE • Name` + подпись `1 CODE = X BASE`.

## Root-cause hypothesis
В [asset_currency_badge_asset_row.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_asset_row.dart) вторичная строка повторяла `code/name` и не содержала rate-информацию.

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
- [asset_currency_badge.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge.dart)
- [asset_currency_badge_bottom_sheet.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_bottom_sheet.dart)

## Implementation note
- Обновлен формат строки в общем currency picker: теперь `CODE • Name` + подпись `rateCaption` во второй строке.
  - [asset_currency_badge_models.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_models.dart)
  - [asset_currency_badge_asset_list.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_asset_list.dart)
  - [asset_currency_badge_asset_row.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_asset_row.dart)
  - [asset_currency_badge_bottom_sheet.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_bottom_sheet.dart)
  - [asset_currency_badge.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge.dart)
- Добавлено вычисление `1 CODE = X BASE` на основе доступного rates snapshot (USD-pivot) и текущей базовой валюты; при отсутствии данных показывается fallback `Rates unavailable`.
- Обновлены/добавлены widget-тесты на новый формат строки, caption с курсом и fallback:
  - [asset_currency_badge_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/asset/widget/asset_currency_badge_test.dart)
  - [add_subaccount_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_page_test.dart)
  - [base_currency_settings_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/settings/page/base_currency_settings_page_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/asset/widget/asset_currency_badge_test.dart` (pass)
  - `cd client && flutter test test/presentation/account/page/add_subaccount_page_test.dart` (pass)
  - `cd client && flutter test test/presentation/settings/page/base_currency_settings_page_test.dart` (pass)
- Пропущено:
  - `cd client && flutter test` (не запускался; выполнены целевые тесты по измененному функционалу).
