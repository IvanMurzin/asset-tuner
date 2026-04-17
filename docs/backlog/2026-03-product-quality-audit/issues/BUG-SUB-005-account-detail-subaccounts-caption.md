# BUG-SUB-005: Добавить caption под список субаккаунтов на Account detail

## Метаданные
- ID: `BUG-SUB-005`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-008`, `SCR-007`

## Экран/модуль/слой
- Экран: Account detail
- Слой: `presentation`

## Проблема
### Текущее поведение
Секция субаккаунтов не содержит поясняющего текста, как использовать список в разных валютах.

### Ожидаемое поведение
Небольшой caption под заголовком секции, поясняющий сценарий добавления счетов в разных валютах.

## Root-cause hypothesis
В текущем `AccountDetailPositionsSection` нет поддерживаемого slot для explanatory copy.

## Предлагаемое решение
1. Добавить caption в секцию.
2. Локализовать текст в `en/ru`.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given account detail screen, when есть/нет subaccounts, then caption отображается консистентно.
2. Given locale switch, when экран открыт, then caption корректно локализован.

## Тест-сценарии
### Manual
1. Проверка caption в обеих локалях.

### Auto
1. Widget test наличия caption.

## Зависимости и блокеры
- Зависит от `IMP-SUB-004`.

## Риски и anti-regression
- Не загромождать экран лишним текстом.

## Ссылки на текущую реализацию
- [account_detail_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/account_detail_page.dart)

## Implementation note
- В [account_detail_positions_section.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/widget/account_detail_positions_section.dart) добавлен локализованный caption под заголовком секции; caption рендерится и при пустом, и при непустом списке счётов.
- В [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb) и [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb) добавлен ключ `subaccountListCaption`.
- Добавлен widget-тест [account_detail_positions_section_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/widget/account_detail_positions_section_test.dart) с проверками caption для empty/non-empty и локали `ru`.
- Пересобраны локализации: [app_localizations.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations.dart), [app_localizations_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_en.dart), [app_localizations_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_ru.dart).
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/account/widget/account_detail_positions_section_test.dart` (pass)
