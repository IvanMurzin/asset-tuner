# BUG-AUTH-003: Ввести `isOTPEnabled` и управлять маршрутом sign-up

## Метаданные
- ID: `BUG-AUTH-003`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-001`, `SCR-015`, `SCR-016`

## Экран/модуль/слой
- Экраны: Sign-up, OTP
- Модуль: `auth`
- Слои: `core/config`, `domain/auth`, `presentation/auth`

## Проблема
### Текущее поведение
После успешного sign-up приложение всегда ведет пользователя на OTP-экран.

### Ожидаемое поведение
Маршрут после sign-up управляется флагом:
- `IS_OTP_ENABLED=true` -> OTP flow,
- `IS_OTP_ENABLED=false` -> immediate authenticated flow (без OTP шага).

## Root-cause hypothesis
В [sign_up_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_up_page.dart) навигация жестко направлена в `AppRoutes.otp`, а `SignUpCubit` не учитывает конфиг-флаг.

## Предлагаемое решение
1. Добавить `isOtpEnabled` в `AppConfig`.
2. Расширить `SignUp` flow: два сценария пост-успеха.
3. При `false` сразу запускать `UserCubit.bootstrap()` и переход в `AppRoutes.main`.
4. Синхронизировать поведение с документацией auth.

## Изменения API/контрактов/конфига
- Новый client config flag `IS_OTP_ENABLED`.

## Acceptance Criteria
1. Given `IS_OTP_ENABLED=true`, when sign-up успешен, then пользователь попадает на OTP экран.
2. Given `IS_OTP_ENABLED=false`, when sign-up успешен, then OTP экран пропускается.
3. Given любой режим, when app restart, then session restore работает консистентно.

## Тест-сценарии
### Manual
1. Прогон signup в двух режимах флага.
2. Проверка возврата из background/kill/restart.

### Auto
1. Unit tests для branching logic в `SignUpCubit`.
2. Widget test навигации sign-up -> otp/main.

## Зависимости и блокеры
- Зависит от `BUG-CONF-001`.

## Риски и anti-regression
- Не сломать существующий OTP flow и resend/verify сценарии.

## Ссылки на текущую реализацию
- [sign_up_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/bloc/sign_up_cubit.dart)
- [sign_up_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_up_page.dart)
- [otp_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/otp_page.dart)
