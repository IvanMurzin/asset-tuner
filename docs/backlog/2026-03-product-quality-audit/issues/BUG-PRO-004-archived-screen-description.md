# BUG-PRO-004: Добавить описание на archived accounts экране

## Метаданные
- ID: `BUG-PRO-004`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Done`
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

## Implementation note
- В [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart) добавлен caption под заголовком archived-экрана в обеих ветках (`empty` и список), текст поясняет, что архивные счета не участвуют в `global total`.
- Для copy добавлен новый l10n-ключ `archivedAccountsGlobalTotalHint` в [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb) и [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb) с последующей генерацией [app_localizations.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations.dart), [app_localizations_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_en.dart), [app_localizations_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_ru.dart).
- Обновлён widget-тест [archived_accounts_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/profile/page/archived_accounts_page_test.dart): добавлена проверка caption в основном navigation-flow и отдельная проверка локализации для `ru`.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/profile/page/archived_accounts_page_test.dart` (pass)
