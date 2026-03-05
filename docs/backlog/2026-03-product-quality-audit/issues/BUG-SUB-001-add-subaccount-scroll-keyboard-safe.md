# BUG-SUB-001: Сделать Add subaccount экран scrollable и keyboard-safe

## Метаданные
- ID: `BUG-SUB-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
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
