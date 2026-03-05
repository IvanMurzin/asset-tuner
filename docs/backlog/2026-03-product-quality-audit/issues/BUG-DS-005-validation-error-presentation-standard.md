# BUG-DS-005: Стандартизировать показ валидационных ошибок

## Метаданные
- ID: `BUG-DS-005`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
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
