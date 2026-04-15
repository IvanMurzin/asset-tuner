# IMP-DS-003: Миграция на feature `AssetCurrencyBadge` + unified bottom sheet

## Метаданные
- ID: `IMP-DS-003`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `SCR-008`, `SCR-011`, `SCR-012`

## Экран/модуль/слой
- Shared feature widget выбора валюты
- Слои: `presentation` + `core_ui`

## Проблема
### Текущее поведение
Выбор валюты оформлен крупной карточкой `DSCurrencyPicker`, что перегружает формы и не соответствует target UX (компактный badge+dropdown).

### Ожидаемое поведение
Появляется компактный reusable feature-виджет `AssetCurrencyBadge` (код валюты + иконка dropdown), который сам открывает bottom sheet и поддерживает режимы `fiat|crypto|all`.

## Root-cause hypothesis
Нет lightweight shared-виджета currency selection с режимами и встроенным tab-switching.

## Предлагаемое решение
1. Удалить `DSCurrencyPicker` и его API.
2. Создать `AssetCurrencyBadge` в `presentation/asset/widget`, bottom sheet читает `AssetsCubit` напрямую.
3. Добавить режимы `CurrencyType.fiat|crypto|all`; для `all` рендерить tabs `Fiat/Crypto` под поиском.
4. Перевести base currency и add subaccount на badge; в add subaccount убрать radio type selector.
5. Добавить `suffix` API в `DSTextField/DSDecimalField` для интеграции badge в поле суммы.

## Изменения API/контрактов/конфига
- Удален API: `DSCurrencyPicker`, `DSCurrencyPickerOption`.
- Добавлен API: `AssetCurrencyBadge`, `CurrencyType`.
- Добавлен optional API `suffix` в `DSTextField` и `DSDecimalField`.

## Acceptance Criteria
1. Given форма с выбором валюты, when рендерится selector, then используется `AssetCurrencyBadge`.
2. Given disabled state, when пользователь нажимает badge, then селектор не открывается.
3. Given locked валюту, when badge tapped, then вызывается paywall-handling callback.

## Тест-сценарии
### Manual
1. Проверка внешнего вида в light/dark/theme modes.

### Auto
1. Widget tests states + callbacks.

## Зависимости и блокеры
- Блокирует `IMP-DS-004`, `BUG-CUR-001`, `BUG-SUB-002`.

## Риски и anti-regression
- Не дублировать бизнес-логику paywall внутри shared widget; только UI callbacks.

## Ссылки на текущую реализацию
- [asset_currency_badge.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/asset/widget/asset_currency_badge.dart)

## Implementation note
- Что сделано:
  - Удален `client/lib/core_ui/components/ds_currency_picker.dart`.
  - Добавлен feature-виджет `client/lib/presentation/asset/widget/asset_currency_badge.dart` с режимами `fiat|crypto|all`, поиском и tabs для `all`.
  - Обновлены `client/lib/presentation/settings/page/base_currency_settings_page.dart` и `client/lib/presentation/account/page/add_subaccount_page.dart` на новый flow выбора валюты.
  - Из `Add subaccount` удалены `fiat/crypto` radio controls.
  - Добавлен optional `suffix` в `client/lib/core_ui/components/ds_text_field.dart` и `client/lib/core_ui/components/ds_decimal_field.dart`.
  - Обновлен `client/lib/core_ui/components/ds_base_currency_value_card.dart` для встраивания badge в карточку.
- Автопроверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/asset/widget/asset_currency_badge_test.dart test/presentation/account/page/add_subaccount_page_test.dart test/presentation/balance/bloc/subaccount_create_cubit_test.dart` (pass)
- Cross-reference:
  - Scope этой задачи также закрывает `IMP-CUR-004` и `BUG-SUB-002`.
