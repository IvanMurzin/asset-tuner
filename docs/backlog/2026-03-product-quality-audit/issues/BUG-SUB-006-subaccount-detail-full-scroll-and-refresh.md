# BUG-SUB-006: На Subaccount detail скроллить весь экран, не только history

## Метаданные
- ID: `BUG-SUB-006`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
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

## Implementation note
- Экран `Subaccount detail` переведён на единый root-scroll: `RefreshIndicator` + `ListView` в [subaccount_detail_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/page/subaccount_detail_page.dart), поэтому теперь скроллится весь экран (header, actions и history вместе).
- Pull-to-refresh подключён на корневом скролле и вызывает `SubaccountInfoCubit.refreshHistory(showLoading: false)`, что ограничивает trigger верхней позицией списка.
- Секция history в [subaccount_history_section.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/widget/subaccount_history_section.dart) убрана из вложенного скролла и встраивается в общий поток страницы, при этом `onLoadMore` и кнопка пагинации сохранены.
- Добавлен widget test [subaccount_detail_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/balance/page/subaccount_detail_page_test.dart):
  - проверяет, что корневой список двигает весь экран;
  - проверяет, что refresh не триггерится вне top-позиции и триггерится из top.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/balance/page/subaccount_detail_page_test.dart` (pass)
