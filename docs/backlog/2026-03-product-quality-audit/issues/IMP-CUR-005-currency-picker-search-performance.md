# IMP-CUR-005: Оптимизировать поиск и рендер currency picker (100+ элементов)

## Метаданные
- ID: `IMP-CUR-005`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-005`, `FTR-003`, `SCR-008`, `SCR-012`

## Экран/модуль/слой
- Currency bottom sheet
- Слои: `core_ui`, `presentation`

## Проблема
### Текущее поведение
Поиск и фильтрация выполняются синхронно на каждом символе; при длинных списках возможны лаги.

### Ожидаемое поведение
Поиск отзывчивый, лист не фризит при 100+ fiat и 100+ crypto.

## Root-cause hypothesis
`_filteredOptions` в picker пересчитывает список на каждый build без оптимизаций.

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
- [ds_currency_picker.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_currency_picker.dart)
