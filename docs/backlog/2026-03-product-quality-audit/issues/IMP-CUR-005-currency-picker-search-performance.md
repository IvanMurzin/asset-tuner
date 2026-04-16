# IMP-CUR-005: Оптимизировать поиск и рендер currency picker (100+ элементов)

## Метаданные
- ID: `IMP-CUR-005`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-005`, `FTR-003`, `SCR-008`, `SCR-012`

## Экран/модуль/слой
- Currency bottom sheet
- Слой: `presentation`

## Проблема
### Текущее поведение
Поиск и фильтрация выполняются синхронно на каждом символе; при длинных списках возможны лаги.

### Ожидаемое поведение
Поиск отзывчивый, лист не фризит при 100+ fiat и 100+ crypto.

## Root-cause hypothesis
Фильтрация и пересчёт row-моделей выполнялись синхронно при каждом обновлении query, без debounce и без предкэша нормализованных ключей.

## Предлагаемое решение
1. Debounce для поиска (краткий).
2. Предкэш normalized search keys.
3. Использовать эффективные list item build patterns.
4. Ограничить тяжелые пересчеты rates-caption.

## Изменения API/контрактов/конфига
- Нет внешних; внутренние оптимизации DS.

## Acceptance Criteria
1. Given список 200+ элементов, when пользователь печатает query, then список фильтруется без заметных лагов.
2. Given быстрый ввод/удаление текста, when query меняется, then UI остается отзывчивым.

## Тест-сценарии
### Manual
1. Performance проверка поиска на длинных списках.

### Auto
1. Unit test фильтрации (корректность).

## Зависимости и блокеры
- Связано с `IMP-CUR-004`.

## Риски и anti-regression
- Не сломать поиск по `code`, `name`, `searchTerms`.

## Ссылки на текущую реализацию
- [asset_currency_badge.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge.dart)
- [asset_currency_badge_bottom_sheet.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_bottom_sheet.dart)
- [asset_currency_badge_asset_list.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_asset_list.dart)
- [asset_currency_search_index.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_search_index.dart)

## Implementation note
- Добавлен debounce поиска в bottom sheet (`120ms`), чтобы исключить `setState` на каждый символ:
  - [asset_currency_badge_bottom_sheet.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_bottom_sheet.dart)
- Вынесен и внедрён предкэш нормализованных search keys (`code`/`name`) через отдельный индекс:
  - [asset_currency_search_index.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_search_index.dart)
  - [asset_currency_badge_asset_list.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge_asset_list.dart)
- Оптимизирован рендер списка: кэш row-моделей с точечным сбросом только при изменении assets/base/rates.
- Добавлен unit test на корректность фильтрации индекса:
  - [asset_currency_search_index_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/asset/widget/asset_currency_search_index_test.dart)
- Regression coverage по picker сохранена:
  - [asset_currency_badge_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/asset/widget/asset_currency_badge_test.dart)
  - [add_subaccount_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_page_test.dart)
  - [base_currency_settings_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/settings/page/base_currency_settings_page_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/asset/widget/asset_currency_search_index_test.dart` (pass)
  - `cd client && flutter test test/presentation/asset/widget/asset_currency_badge_test.dart` (pass)
  - `cd client && flutter test test/presentation/account/page/add_subaccount_page_test.dart` (pass)
  - `cd client && flutter test test/presentation/settings/page/base_currency_settings_page_test.dart` (pass)
- Пропущено:
  - `cd client && flutter test` (не запускался; выполнены целевые unit/widget тесты по измененному модулю).
