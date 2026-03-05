# BUG-AUTH-004: Исправить перекрытие полей клавиатурой на auth-экранах

## Метаданные
- ID: `BUG-AUTH-004`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-002`, `SCR-015`, `SCR-016`

## Экран/модуль/слой
- Экраны: Sign-in, Sign-up, OTP
- Слой: `presentation`

## Проблема
### Текущее поведение
На auth-экранах используется `resizeToAvoidBottomInset: false`; при фокусе нижние поля/кнопки могут уходить под клавиатуру.

### Ожидаемое поведение
Любое поле ввода и primary CTA остаются доступными во время ввода, экран корректно прокручивается.

## Root-cause hypothesis
В [sign_in_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_in_page.dart), [sign_up_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_up_page.dart), [otp_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/otp_page.dart) отключен resize и нет keyboard-aware контейнера.

## Предлагаемое решение
1. Сделать layout keyboard-safe (`resizeToAvoidBottomInset=true` или эквивалент).
2. Сохранить UX-структуру с sticky footer CTA.
3. Добавить единый паттерн прокрутки для auth-форм.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given фокус на нижнем поле, when клавиатура открывается, then поле не перекрывается.
2. Given клавиатура открыта, when пользователь скроллит, then любой input/CTA доступен.
3. Given iOS/Android, when ввод завершается, then layout возвращается без артефактов.

## Тест-сценарии
### Manual
1. Проверка на small-screen устройствах и landscape.
2. Ввод в последнем поле + переход к кнопке.

### Auto
1. Widget tests на наличие scrollable контейнера и доступность CTA.

## Зависимости и блокеры
- Может использовать общий паттерн из `BUG-DS-001`.

## Риски и anti-regression
- Не допустить прыжков layout при появлении snackbar/ошибок.

## Ссылки на текущую реализацию
- [sign_in_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_in_page.dart)
- [sign_up_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_up_page.dart)
- [otp_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/otp_page.dart)
