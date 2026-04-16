# BUG-SUB-001: Сделать Add subaccount экран scrollable и keyboard-safe

## Метаданные
- ID: `BUG-SUB-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-005`, `SCR-008`

## Экран/модуль/слой
- Экран: Add subaccount
- Слой: `presentation`

## Проблема
### Текущее поведение
Форма add-subaccount построена через `Column` со `Spacer`; при открытой клавиатуре часть полей/кнопок может быть перекрыта.

### Ожидаемое поведение
Экран полностью прокручиваемый, все поля и CTA доступны при любом состоянии клавиатуры.

## Root-cause hypothesis
В [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart) отсутствует keyboard-aware layout pattern.

## Предлагаемое решение
1. Перевести контент на scrollable form-layout с safe insets.
2. Совместить с `BUG-DS-001` (dismiss keyboard tap outside).
3. Проверить доступность CTA при фокусе на нижних полях.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given клавиатура открыта, when фокус в нижнем input, then поле и CTA не перекрыты.
2. Given длинный контент, when пользователь скроллит, then все элементы доступны.

## Тест-сценарии
### Manual
1. Проверка на малых экранах iOS/Android.

### Auto
1. Widget test наличия scrollable root.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не нарушить текущую логику success-navigation.

## Ссылки на текущую реализацию
- [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)

## Implementation note
- Экран `Add subaccount` переведён на scrollable-root: вместо статичного `Column` используется `ListView` с `keyboardDismissBehavior: onDrag`.
- Добавлен keyboard-safe отступ снизу через `MediaQuery.viewInsetsOf(context).bottom`, чтобы CTA оставалась доступной при открытой клавиатуре.
- Сохранена текущая бизнес-логика сабмита/валидации/навигации; изменён только layout-слой.
- Добавлен widget test на наличие scrollable root:
  - [add_subaccount_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_page_test.dart)
- Изменённые файлы:
  - [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)
  - [add_subaccount_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_page_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/account/page/add_subaccount_page_test.dart` (pass)
- Пропущено:
  - `cd client && flutter test` (не запускался; выполнен целевой тест по изменённому экрану).
