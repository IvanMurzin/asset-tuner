# BUG-AUTH-002: Подготовить и подключить Google/Apple auth (dev+prod)

## Метаданные
- ID: `BUG-AUTH-002`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FR-002`, `FTR-001`, `SCR-002`

## Экран/модуль/слой
- Экран: Sign-in
- Модуль: `auth`
- Слои: `presentation`, `data`, `core/config`, `backend/auth setup`

## Проблема
### Текущее поведение
OAuth кнопки в UI есть, но отсутствует формализованная задача по полному конфигурированию ключей и environment-полей в клиенте.

### Ожидаемое поведение
Google/Apple auth работают в dev и prod по единому documented flow, а необходимые поля конфигурации явно определены.

## Root-cause hypothesis
Конфиг-контракт в [app_config.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/config/app_config.dart) не содержит OAuth-параметры, а процесс owner-настройки разрознен.

## Предлагаемое решение
1. Добавить поля OAuth в `AppConfig` и `.config*.json` (через placeholders).
2. Зафиксировать owner-чеклист действий в Supabase/Auth providers.
3. Проверить end-to-end для `signInWithOAuth(google|apple)`.

## Изменения API/контрактов/конфига
- `AppConfig` расширяется OAuth-полями.
- `.config.dev.json`/`.config.prod.json`/examples обновляются новыми ключами.

## Acceptance Criteria
1. Given OAuth настроен в Supabase, when пользователь нажимает Google/Apple, then логин завершается с переходом в main flow.
2. Given отсутствует корректный конфиг, when приложение стартует, then ошибка конфигурации детерминированна и диагностируема.
3. Given dev/prod окружения, when запускается auth flow, then используются окружение-специфичные ключи.

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
