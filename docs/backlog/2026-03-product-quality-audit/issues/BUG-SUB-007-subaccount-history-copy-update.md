# BUG-SUB-007: Обновить copy блока истории на Subaccount detail

## Метаданные
- ID: `BUG-SUB-007`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Draft`
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
