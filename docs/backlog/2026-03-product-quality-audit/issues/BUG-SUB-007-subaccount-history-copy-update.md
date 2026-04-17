# BUG-SUB-007: Обновить copy блока истории на Subaccount detail

## Метаданные
- ID: `BUG-SUB-007`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-006`, `SCR-010`

## Экран/модуль/слой
- Экран: Subaccount detail
- Слой: `presentation/l10n`

## Проблема
### Текущее поведение
Текущие заголовки/описания history не максимально понятны для пользователя.

### Ожидаемое поведение
Секция называется “Your balance history” + краткое полезное описание, объясняющее смысл изменений баланса.

## Root-cause hypothesis
Тексты наследованы из ранней версии экрана и не отражают язык snapshot-модели.

## Предлагаемое решение
1. Обновить copy в `en/ru` для заголовка и подписи history.
2. Согласовать термины с `IMP-SUB-004`.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given subaccount detail screen, when history section отображается, then заголовок/description соответствуют новому copy.
2. Given locale switch, when экран открыт, then copy корректно локализован.

## Тест-сценарии
### Manual
1. Проверка текста на `en` и `ru`.

### Auto
1. L10n regression test ключей.

## Зависимости и блокеры
- Связано с `IMP-SUB-004`.

## Риски и anti-regression
- Не вводить двусмысленность между history и analytics updates.

## Ссылки на текущую реализацию
- [subaccount_history_section.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/widget/subaccount_history_section.dart)
- [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb)
- [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb)

## Implementation note
- В [subaccount_history_section.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/balance/widget/subaccount_history_section.dart) под заголовком секции добавлена локализованная подпись `positionHistoryDescription`, объясняющая смысл изменений баланса по snapshot-обновлениям.
- Обновлен copy заголовка секции history в [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb) и [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb):
  - `en`: `Your balance history`
  - `ru`: `История баланса счёта`
- Добавлен новый l10n-ключ `positionHistoryDescription` в `en/ru` и синхронизированы сгенерированные файлы локализации:
  - [app_localizations.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations.dart)
  - [app_localizations_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_en.dart)
  - [app_localizations_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_ru.dart)
- Обновлен widget-тест [subaccount_detail_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/balance/page/subaccount_detail_page_test.dart): добавлена проверка нового history copy в `en` и `ru`.
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/balance/page/subaccount_detail_page_test.dart` (pass)
