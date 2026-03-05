# BUG-CONF-001: Расширить AppConfig и `.config*.json` для auth-флагов и OAuth placeholders

## Метаданные
- ID: `BUG-CONF-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-001`, `FTR-003`, auth flow

## Экран/модуль/слой
- Конфиг приложения
- Слой: `core/config`

## Проблема
### Текущее поведение
Конфиг приложения не содержит `IS_OTP_ENABLED` и OAuth-поля, необходимые для управляемого auth flow.

### Ожидаемое поведение
`AppConfig` и `.config.dev/.config.prod` включают все необходимые auth-related define-поля с placeholders.

## Root-cause hypothesis
`AppConfig.requireFromEnvironment()` валидирует только базовый набор ключей.

## Предлагаемое решение
1. Добавить поля в `AppConfig` и `tryFromEnvironment`.
2. Обновить `.config*.json.example` новыми полями.
3. Добавить documentation в owner-checklist.

## Изменения API/контрактов/конфига
- Новый client config contract:
  - `IS_OTP_ENABLED`
  - OAuth IDs/placeholders.

## Acceptance Criteria
1. Given missing required auth keys, when app стартует, then ошибка конфигурации явная.
2. Given keys присутствуют, when app стартует, then config инициализируется успешно.

## Тест-сценарии
### Manual
1. Запуск с полным/неполным конфигом.

### Auto
1. Unit tests `AppConfig.tryFromEnvironment`.

## Зависимости и блокеры
- Блокирует `BUG-AUTH-003` и часть `BUG-AUTH-002`.

## Риски и anti-regression
- Не сделать чрезмерно строгую валидацию, если часть полей опциональна для окружения.

## Ссылки на текущую реализацию
- [app_config.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/config/app_config.dart)
- [.config.dev.json.example](/Users/ivanmurzin/Projects/pets/asset_tuner/.config.dev.json.example)
- [.config.prod.json.example](/Users/ivanmurzin/Projects/pets/asset_tuner/.config.prod.json.example)
