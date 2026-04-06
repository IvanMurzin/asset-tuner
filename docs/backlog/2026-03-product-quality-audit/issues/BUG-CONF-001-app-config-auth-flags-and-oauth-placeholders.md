# BUG-CONF-001: Актуализировать auth config contract и OAuth placeholders

## Метаданные
- ID: `BUG-CONF-001`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-001`, `FTR-003`, auth flow

## Экран/модуль/слой
- Конфиг приложения
- Слой: `core/config`

## Проблема
### Текущее поведение
Документация и `.config*.json.example` были рассинхронизированы с фактической схемой auth.
OAuth в приложении работает через Supabase provider config + `OAUTH_REDIRECT_URI`, при этом часть OAuth ключей в client config не используется в рантайме.

### Ожидаемое поведение
Client config содержит только реально используемые auth-поля, а документация явно разделяет:
1. client `--dart-define` контракт;
2. OAuth provider credentials в Supabase Dashboard.

## Root-cause hypothesis
Исторический дрейф документации после внедрения OAuth/OTP: часть полей осталась в шаблонах как legacy placeholders.

## Предлагаемое решение
1. Оставить в `AppConfig` только реально используемые auth defines (`OAUTH_REDIRECT_URI`, `IS_OTP_ENABLED`).
2. Синхронизировать `.config.dev/.config.prod` examples с фактическим runtime-контрактом.
3. Обновить owner-checklist: OAuth client ids/secrets настраиваются в Supabase, не в `dart-define`.

## Изменения API/контрактов/конфига
- Актуализированный client config contract:
  - `OAUTH_REDIRECT_URI` (required string),
  - `IS_OTP_ENABLED` (optional bool, default `false`).
- Удалены лишние OAuth placeholders (`GOOGLE_*`, `APPLE_SERVICE_ID`) из `.config*.json.example`.

## Acceptance Criteria
1. Given missing required runtime auth key (`OAUTH_REDIRECT_URI`), when app стартует, then ошибка конфигурации явная.
2. Given keys присутствуют, when app стартует, then config инициализируется успешно.
3. Given owner настраивает OAuth провайдеры, when проверяется checklist, then в документации нет требований по неиспользуемым client OAuth keys.

## Тест-сценарии
### Manual
1. Запуск с полным/неполным конфигом (`OAUTH_REDIRECT_URI`).
2. Проверка owner checklist: OAuth credentials на стороне Supabase.

### Auto
1. Smoke: `flutter analyze`.

## Зависимости и блокеры
- Блокирует `BUG-AUTH-003` и часть `BUG-AUTH-002`.

## Риски и anti-regression
- Не требовать в рантайме ключи, которые реально не читаются приложением.

## Ссылки на текущую реализацию
- [app_config.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/config/app_config.dart)
- [.config.dev.json.example](/Users/ivanmurzin/Projects/pets/asset_tuner/.config.dev.json.example)
- [.config.prod.json.example](/Users/ivanmurzin/Projects/pets/asset_tuner/.config.prod.json.example)

## Implementation note
- Что сделано: синхронизированы `.config.dev/.config.prod` examples с фактическим runtime-контрактом (`OAUTH_REDIRECT_URI`, `IS_OTP_ENABLED`), удалены неиспользуемые OAuth placeholders из examples, обновлен owner-checklist с явным разделением client config и Supabase provider credentials.
- Измененные файлы: `.config.dev.json.example`, `.config.prod.json.example`, `docs/backlog/2026-03-product-quality-audit/OWNER-CHECKLIST-auth-config.md`, `docs/backlog/2026-03-product-quality-audit/INDEX.md`, `docs/backlog/2026-03-product-quality-audit/issues/BUG-CONF-001-app-config-auth-flags-and-oauth-placeholders.md`.
- Проверки: `cd client && flutter analyze` (pass), `cd client && flutter test test/data/auth/data_source/supabase_auth_data_source_test.dart` (pass).
