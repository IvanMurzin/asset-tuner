# BUG-CONF-002: Использовать системные theme/locale по умолчанию, prefs только после user override

## Метаданные
- ID: `BUG-CONF-002`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-002`, `SCR-009`, app bootstrap

## Экран/модуль/слой
- Глобальное поведение приложения
- Слой: `core/localization`, `core_ui/theme`, `app bootstrap`

## Проблема
### Текущее поведение
`LocaleCubit.load()` принудительно записывает `en` при отсутствии сохраненного значения, что ломает default behavior “follow system”.

### Ожидаемое поведение
Если пользователь не выбирал override, приложение следует системным theme/locale; запись в storage происходит только при явном выборе пользователя.

## Root-cause hypothesis
В [locale_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/localization/locale_cubit.dart) есть eager write `en` на первом запуске.

## Предлагаемое решение
1. Добавить tri-state подход:
   - `null` = system,
   - `en/ru` = explicit override.
2. Не писать default в storage до явного выбора.
3. Согласовать логику с `ThemeModeCubit` и UI selector’ами.

## Изменения API/контрактов/конфига
- Нет внешних; внутренний контракт local storage locale/theme.

## Acceptance Criteria
1. Given чистая установка, when app стартует, then locale/theme соответствуют system settings.
2. Given пользователь выбрал override, when app restart, then выбранное значение сохраняется.
3. Given user resets to system, when app restart, then снова применяется system.

## Тест-сценарии
### Manual
1. Чистая установка на `ru` system locale.
2. Смена locale/theme и возврат в system.

### Auto
1. Unit tests locale/theme storage semantics.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не поломать перевод ошибок через `SupabaseErrorTranslator`.

## Ссылки на текущую реализацию
- [locale_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/localization/locale_cubit.dart)
- [theme_mode_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/theme/theme_mode_cubit.dart)
- [app.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/app.dart)
