# BUG-DS-001: Глобальный dismiss клавиатуры при тапе вне input

## Метаданные
- ID: `BUG-DS-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-002`, `SCR-015`, `SCR-008`, `SCR-011`

## Экран/модуль/слой
- Сквозное поведение на формах
- Слой: `core_ui` + `presentation`

## Проблема
### Текущее поведение
На экранах ввода нет единого поведения dismiss клавиатуры по тапу в свободную область; решение приходится дублировать по экранам.

### Ожидаемое поведение
Единый reusable паттерн: тап вне input закрывает клавиатуру на iOS/Android.

## Root-cause hypothesis
В DS не выделен общий form-container/gesture-wrapper для unfocus.

## Предлагаемое решение
1. Добавить DS-обертку для форм (например, `DSKeyboardDismissArea`).
2. Применить в ключевых экранах ввода.
3. Стандартизировать поведение в ux/docs.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given клавиатура открыта, when пользователь тапает вне input, then клавиатура скрывается.
2. Given экран с несколькими input, when фокус на одном из полей и тач вне полей, then focus снимается.
3. Given iOS/Android, when сценарий повторяется, then поведение одинаково.

## Тест-сценарии
### Manual
1. Проверить dismiss на auth/create-subaccount/set-balance.

### Auto
1. Widget test на `FocusScope.unfocus` при tap outside.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не ломать onTap у интерактивных элементов внутри формы.

## Ссылки на текущую реализацию
- [ds_text_field.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_text_field.dart)
- [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)
