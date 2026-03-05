# BUG-PRO-004: Добавить описание на archived accounts экране

## Метаданные
- ID: `BUG-PRO-004`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-004`, `SCR-009`

## Экран/модуль/слой
- Экран: Archived accounts
- Слой: `presentation/l10n`

## Проблема
### Текущее поведение
Экран архивов не поясняет, что архивные аккаунты исключены из общего баланса.

### Ожидаемое поведение
Под заголовком есть краткое описание: архивные счета не участвуют в global total.

## Root-cause hypothesis
Отсутствует dedicated caption на экране архивов.

## Предлагаемое решение
1. Добавить caption в верхней части экрана.
2. Локализовать copy.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given archived screen, when экран открыт, then пользователь видит explanatory текст.
2. Given locale switch, when экран открыт, then текст корректно локализован.

## Тест-сценарии
### Manual
1. Проверка текста в `en/ru`.

### Auto
1. Widget test caption visibility.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Избежать визуального шума в шапке экрана.

## Ссылки на текущую реализацию
- [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart)
