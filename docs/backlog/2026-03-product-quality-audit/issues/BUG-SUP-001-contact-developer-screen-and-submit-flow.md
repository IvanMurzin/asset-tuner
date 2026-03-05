# BUG-SUP-001: Добавить экран Contact developer и submit flow в `api/contact_developer`

## Метаданные
- ID: `BUG-SUP-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
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
