# BUG-SUB-006: На Subaccount detail скроллить весь экран, не только history

## Метаданные
- ID: `BUG-SUB-006`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-006`, `SCR-010`

## Экран/модуль/слой
- Экран: Subaccount detail
- Слой: `presentation`

## Проблема
### Текущее поведение
В [subaccount_detail_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/subaccount_detail_page.dart) верхняя часть статична, скролл сосредоточен в секции history, что делает UX неравномерным.

### Ожидаемое поведение
Скроллится весь экран целиком; pull-to-refresh срабатывает только из верхней позиции.

## Root-cause hypothesis
Текущий layout: `Column` + `Expanded(history)`, где scroll container находится только внутри нижней части.

## Предлагаемое решение
1. Перестроить страницу в единый `CustomScrollView`/эквивалент.
2. Сохранить lazy/pagination для history.
3. Перепроверить pull-to-refresh trigger condition.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given экран subaccount detail, when пользователь скроллит, then движется весь экран.
2. Given пользователь тянет refresh не из top, when gesture происходит, then refresh не триггерится.
3. Given top reached, when pull-to-refresh, then данные обновляются как раньше.

## Тест-сценарии
### Manual
1. Проверить scroll + refresh с длинной history.

### Auto
1. Widget test с проверкой refresh trigger из top.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не сломать onLoadMore и сохранение позиции списка.

## Ссылки на текущую реализацию
- [subaccount_detail_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/subaccount_detail_page.dart)
