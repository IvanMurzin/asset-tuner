# BUG-DS-001: Глобальный dismiss клавиатуры при тапе вне input

## Метаданные
- ID: `BUG-DS-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
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
1. Добавить callback dismiss клавиатуры в DS input-компоненты (`onTapOutside` -> `unfocus`).
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

## Implementation note
- Что сделано: dismiss клавиатуры перенесен в DS input-компоненты через `onTapOutside` с `FocusManager.instance.primaryFocus?.unfocus()`.
- Применение: поведение работает глобально на экранах, использующих `DSTextField`/`DSPasswordField`/`DSSearchField` (включая `SCR-002`, `SCR-015`, `SCR-008`, `SCR-011`) без page-level оберток.
- UX/docs: в screen docs для `SCR-002`, `SCR-015`, `SCR-008`, `SCR-011` зафиксирован стандарт через DS input callback.
- Тесты: добавлен widget test `ds_text_field_keyboard_dismiss_test.dart` на сценарий tap outside -> unfocus.
- Измененные файлы: `client/lib/core_ui/components/ds_text_field.dart`, `client/lib/core_ui/components/ds_password_field.dart`, `client/lib/core_ui/components/ds_search_field.dart`, `client/test/core_ui/components/ds_text_field_keyboard_dismiss_test.dart`, `docs/ux/screens/SCR-002-sign-in.md`, `docs/ux/screens/SCR-015-sign-up.md`, `docs/ux/screens/SCR-008-create-subaccount.md`, `docs/ux/screens/SCR-011-update-balance.md`, `docs/backlog/2026-03-product-quality-audit/INDEX.md`.
- Проверки: `cd client && flutter analyze` (pass), `cd client && flutter test test/core_ui/components/ds_text_field_keyboard_dismiss_test.dart` (pass).
