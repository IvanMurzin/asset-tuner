# BUG-SUP-001: Добавить экран Contact developer и submit flow в `api/contact_developer`

## Метаданные
- ID: `BUG-SUP-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `SCR-009`, support flow

## Экран/модуль/слой
- Экран: Profile -> Contact developer
- Слои: `presentation`, `domain`, `data`, `backend contract verification`

## Проблема
### Текущее поведение
Backend маршрут `POST /api/contact_developer` уже существует, но пользовательского UI и клиентского submit-flow нет.

### Ожидаемое поведение
В профиле доступен экран обратной связи: email пользователя (readonly) + textarea, отправка в backend и toast “Спасибо, что поделились”.

## Root-cause hypothesis
Функция добавлена на backend раньше UI-реализации.

## Предлагаемое решение
1. Добавить route и страницу Contact developer в profile flow.
2. Реализовать форму: readonly email + message textarea.
3. Подключить endpoint `api/contact_developer` и success/error feedback.

## Изменения API/контрактов/конфига
- Подтвердить соответствие payload полям backend validation.
- При расхождении создать follow-up issue на выравнивание.

## Acceptance Criteria
1. Given профиль пользователя, when он открывает Contact developer, then email поле префиллено и disabled.
2. Given заполнено сообщение, when нажата отправка, then запись уходит в backend и показывается success toast.
3. Given сетевой сбой, when отправка неуспешна, then показывается retryable error.

## Тест-сценарии
### Manual
1. Успешная отправка и проверка записи в таблице support.
2. Ошибка сети и повторная попытка.

### Auto
1. Unit tests для repository/data-source submit.
2. Widget tests формы и disabled email.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не дублировать отправки при повторном нажатии CTA.

## Ссылки на текущую реализацию
- [supabase_constants.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/supabase/supabase_constants.dart)
- [api/index.ts](/Users/ivanmurzin/Projects/pets/asset_tuner/backend/supabase/functions/api/index.ts)

## Implementation note

### Root cause
`POST /api/contact_developer` был реализован только на backend-стороне, но в profile flow отсутствовали route, экран формы и client submit orchestration.

### Changed files
- `client/lib/presentation/profile/page/contact_developer_page.dart` — добавлен экран Contact developer: readonly email, textarea сообщения, submit/error handling, защита от повторной отправки в loading.
- `client/lib/presentation/profile/page/profile_page.dart` — добавлен entry-point `Contact developer` в секцию support и success toast после успешной отправки.
- `client/lib/core/routing/app_routes.dart` и `client/lib/core/routing/app_router.dart` — добавлен маршрут `/profile/contact-developer`.
- `client/lib/domain/profile/repository/i_profile_repository.dart` — добавлен контракт `sendContactDeveloperMessage(...)`.
- `client/lib/data/profile/data_source/supabase_profile_data_source.dart` — реализован submit в `api/contact_developer` с payload, соответствующим backend validation (`name`, `email?`, `description`).
- `client/lib/data/profile/repository/profile_repository.dart` — добавлен repository flow с map ошибок через `SupabaseFailureMapper`.
- `client/lib/l10n/app_en.arb`, `client/lib/l10n/app_ru.arb`, `client/lib/l10n/app_localizations*.dart` — добавлен copy для support-section, contact-form, success/error UX.
- `client/test/data/profile/data_source/supabase_profile_data_source_test.dart` — unit-тесты payload/endpoint и optional email.
- `client/test/data/profile/repository/profile_repository_test.dart` — unit-тесты success/failure для repository submit.
- `client/test/presentation/profile/page/contact_developer_page_test.dart` — widget-тесты readonly email и retryable error с повторной отправкой.
- `client/test/presentation/profile/page/profile_page_test.dart` — тест перехода в Contact developer из Profile.
- `docs/contracts/api_surface.md` — зафиксирован контракт `POST /contact_developer`.

### Checks
- `cd client && flutter test test/presentation/profile/page/profile_page_test.dart test/presentation/profile/page/contact_developer_page_test.dart test/data/profile/data_source/supabase_profile_data_source_test.dart test/data/profile/repository/profile_repository_test.dart` (pass)
- `cd client && flutter analyze` (pass)
