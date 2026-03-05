# Owner Checklist: OAuth + Auth Config Setup

## Назначение
Чеклист действий владельца проекта для корректной интеграции Google/Apple auth и конфиг-флагов в dev/prod окружениях.

## 1) Что должен подготовить владелец
1. `Google OAuth Client ID` для iOS и Android (и при необходимости web callback).
2. `Apple Sign In` identifiers:
   - Services ID / Client ID,
   - Team ID,
   - Key ID,
   - private key (`.p8`) для backend-секрета.
3. Redirect URL, используемые Supabase Auth (из dashboard проекта).

## 2) Что добавить в клиентские конфиги (placeholders)
В `.config.dev.json` и `.config.prod.json` должны быть добавлены поля:
1. `IS_OTP_ENABLED` (`true|false`)
2. `GOOGLE_IOS_CLIENT_ID`
3. `GOOGLE_ANDROID_CLIENT_ID`
4. `APPLE_SERVICE_ID`
5. `APPLE_REDIRECT_URI` (если требуется текущим SDK flow)

Примечание: значения секретов не коммитятся в репозиторий; используются локальные файлы конфигурации.

## 3) Что включить в Supabase Dashboard
1. Auth -> Providers -> Google: включить, указать client id/secret.
2. Auth -> Providers -> Apple: включить, указать service id / key id / team id / private key.
3. Auth -> URL Configuration: проверить `Site URL` и `Redirect URLs` под mobile flow.

## 4) Проверки после настройки
1. Вход Google проходит end-to-end и возвращает пользователя в приложение.
2. Вход Apple проходит end-to-end и возвращает пользователя в приложение.
3. При `IS_OTP_ENABLED=false` sign-up не отправляет на OTP экран.
4. При `IS_OTP_ENABLED=true` sign-up ведет на OTP экран.
5. Session restore после перезапуска работает для всех auth providers.

## 5) Анти-риски
1. Не смешивать ключи dev/prod проектов Supabase.
2. Проверить, что в проде включены только production redirect URLs.
3. При ротации Apple key обновить секреты в Supabase и задокументировать дату ротации.
