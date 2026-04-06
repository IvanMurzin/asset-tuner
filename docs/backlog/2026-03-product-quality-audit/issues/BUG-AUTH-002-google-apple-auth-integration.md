# BUG-AUTH-002: Подготовить и подключить Google/Apple auth (dev+prod)

## Метаданные
- ID: `BUG-AUTH-002`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FR-002`, `FTR-001`, `SCR-002`

## Экран/модуль/слой
- Экран: Sign-in
- Модуль: `auth`
- Слои: `presentation`, `data`, `core/config`, `backend/auth setup`

## Проблема
### Текущее поведение
OAuth кнопки в UI есть, но процесс owner-настройки провайдеров в Supabase и mobile redirect flow не был формализован в одном месте.

### Ожидаемое поведение
Google/Apple auth работают в dev и prod по единому documented flow, а responsibilities между client config и Supabase provider settings явно определены.

## Root-cause hypothesis
Процесс owner-настройки был разрознен: какие параметры задаются через client config, а какие через Supabase Auth Providers, было описано неполно.

## Предлагаемое решение
1. Зафиксировать минимальный client config для OAuth-flow (`OAUTH_REDIRECT_URI`) без дублирования provider credentials в app config.
2. Зафиксировать owner-чеклист действий в Supabase/Auth providers.
3. Проверить end-to-end для `signInWithOAuth(google|apple)`.

## Изменения API/контрактов/конфига
- Client config использует `OAUTH_REDIRECT_URI` для mobile callback.
- OAuth provider credentials хранятся и настраиваются в Supabase Dashboard.

## Acceptance Criteria
1. Given OAuth настроен в Supabase, when пользователь нажимает Google/Apple, then логин завершается с переходом в main flow.
2. Given отсутствует корректный конфиг, when приложение стартует, then ошибка конфигурации детерминированна и диагностируема.
3. Given dev/prod окружения, when запускается auth flow, then используются окружение-специфичные настройки Supabase providers и redirect URLs.

## Тест-сценарии
### Manual
1. Google sign-in success/failure в dev.
2. Apple sign-in success/failure в dev.
3. Проверка production-ready checklist.

### Auto
1. Unit тест маппинга провайдеров в `SupabaseAuthDataSource`.

## Зависимости и блокеры
- Зависит от owner-provided credentials.

## Риски и anti-regression
- Не зашивать реальные секреты в репозиторий.

## Ссылки на текущую реализацию
- [sign_in_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/auth/page/sign_in_page.dart)
- [supabase_auth_data_source.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/data/auth/data_source/supabase_auth_data_source.dart)
- [app_config.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/config/app_config.dart)

## Implementation note
- Зафиксирован рабочий OAuth flow через Supabase providers + `OAUTH_REDIRECT_URI` в client config.
- Обновлены `.config.dev/.prod` и `.example` для единообразного OAuth redirect контракта.
- В `SupabaseAuthDataSource` выделен тестируемый маппинг `AuthProvider -> OAuthProvider` и добавлен unit test.
- Обновлён owner checklist по OAuth setup в Supabase/Auth providers.
- Проверки: `flutter analyze` (pass), `flutter test test/data/auth/data_source/supabase_auth_data_source_test.dart` (pass).
