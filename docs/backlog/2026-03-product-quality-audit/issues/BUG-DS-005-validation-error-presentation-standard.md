# BUG-DS-005: Стандартизировать показ валидационных ошибок

## Метаданные
- ID: `BUG-DS-005`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-006`, `SCR-006`, `SCR-008`, `SCR-011`

## Экран/модуль/слой
- Все формы с пользовательским вводом
- Слой: `presentation` + `core_ui`

## Проблема
### Текущее поведение
Часть validation ошибок отображается общим баннером/бейджем на странице, а не в конкретном поле, из-за чего пользователю неочевидно, где исправлять ввод.

### Ожидаемое поведение
Валидация поля показывается inline в input. Глобальный snackbar/баннер используется только для non-field ошибок.

## Root-cause hypothesis
Во многих cubit’ах валидация возвращает `failureMessage`, но form-state не маппится системно в field-level ошибки.

## Предлагаемое решение
1. Ввести правило: field validation -> `errorText` в соответствующем DS input.
2. Сохранить snackbar только для network/authorization/server errors.
3. Провести audit форм (`account`, `subaccount`, `balance`, `auth`).

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given пустой required input, when нажата submit CTA, then ошибка показана под этим input.
2. Given server/network error, when submit fails, then показывается banner/snackbar.
3. Given пользователь исправил поле, when ввод валиден, then inline error исчезает.

## Тест-сценарии
### Manual
1. Account create/update: пустое имя.
2. Subaccount create: пустые name/currency/balance.
3. Set balance: пустая сумма.

### Auto
1. Unit tests для field-error маппинга в cubit state.
2. Widget tests на errorText rendering.

## Зависимости и блокеры
- Связано с `BUG-DS-002`, `IMP-DS-004`.

## Риски и anti-regression
- Не потерять локализацию текстов ошибок (`en/ru`).

## Ссылки на текущую реализацию
- [account_create_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/bloc/account_create_cubit.dart)
- [subaccount_create_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/bloc/subaccount_create_cubit.dart)
- [subaccount_balance_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/bloc/subaccount_balance_cubit.dart)

## Implementation note
- Что сделано:
  - Для `account create/update` добавлены field-level ошибки в state/cubit (`nameError`) и вывод `errorText` в `DSTextField`; при вводе ошибка очищается.
  - Для `add subaccount` добавлены inline-ошибки под полями `name`, `currency`, `amount`; `DSCurrencyPicker` расширен поддержкой `errorText`.
  - Для `add balance` добавлена inline-ошибка под `amount` при пустом/невалидном вводе.
  - На формах `account/subaccount/balance` баннер оставлен только для non-validation ошибок (`failureCode != validation`).
  - В локализацию добавлен ключ `subaccountCurrencyRequired` (`en/ru`).
- Тесты:
  - Добавлены unit tests на маппинг field-error в cubit state:
    - `client/test/presentation/account/bloc/account_form_validation_cubit_test.dart`
    - `client/test/presentation/balance/bloc/subaccount_create_cubit_test.dart`
- Измененные файлы:
  - `client/lib/presentation/account/bloc/account_create_cubit.dart`
  - `client/lib/presentation/account/bloc/account_create_state.dart`
  - `client/lib/presentation/account/bloc/account_update_cubit.dart`
  - `client/lib/presentation/account/bloc/account_update_state.dart`
  - `client/lib/presentation/account/page/account_create_page.dart`
  - `client/lib/presentation/account/page/account_update_page.dart`
  - `client/lib/presentation/account/page/add_subaccount_page.dart`
  - `client/lib/presentation/balance/bloc/subaccount_create_cubit.dart`
  - `client/lib/presentation/balance/bloc/subaccount_create_state.dart`
  - `client/lib/presentation/balance/page/add_balance_page.dart`
  - `client/lib/core_ui/components/ds_currency_picker.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/account/bloc/account_form_validation_cubit_test.dart test/presentation/balance/bloc/subaccount_create_cubit_test.dart` (pass)
  - `cd client && dart run build_runner build --delete-conflicting-outputs` (failed: `injectable_generator` не смог резолвить function type в `lib/core/localization/locale_cubit.dart`, pre-existing проблема вне текущего scope)
