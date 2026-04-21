# BUG-PRO-005: Переработать paywall visual hierarchy

## Метаданные
- ID: `BUG-PRO-005`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-009`, `SCR-013`

## Экран/модуль/слой
- Экран: Paywall
- Слой: `presentation`

## Проблема
### Текущее поведение
Визуальная иерархия paywall перегружена: global “most popular” на Pro конфликтует с плановым выбором monthly/annual.

### Ожидаемое поведение
- Free секция более нейтральная (серый стиль),
- Pro секция визуально выделена,
- badge “most popular” только на annual-плане.

## Root-cause hypothesis
Текущая структура paywall использует конкурирующие акценты и не фокусирует пользователя на выборе plan duration.

## Предлагаемое решение
1. Обновить карточки планов и секций free/pro.
2. Удалить global badge у Pro и перенести акцент на annual.
3. Сохранить текущую purchase/restore логику.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given paywall открыт, when пользователь видит планы, then annual имеет badge, Pro-header без global badge.
2. Given пользователь переключает monthly/annual, when CTA pressed, then purchase flow неизменен.

## Тест-сценарии
### Manual
1. Проверка visual states + selection plans.

### Auto
1. Snapshot tests paywall states.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не ухудшить конверсию из-за чрезмерной декоративности.

## Ссылки на текущую реализацию
- [paywall_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/paywall/page/paywall_page.dart)

## Implementation note
- В [paywall_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/paywall/page/paywall_page.dart) badge `paywallMostPopular` перенесён с Pro-секции на annual option в `PaywallPlanToggle`; глобальный badge у Pro удалён, purchase/restore flow не менялся.
- В [paywall_plan_toggle.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/paywall/widget/paywall_plan_toggle.dart) добавлен `annualBadgeText` и визуализация badge внутри annual-плашки.
- В [paywall_tier_card.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/paywall/widget/paywall_tier_card.dart) добавлен `neutral`-режим для Free-карточки (более нейтральная серая подача), при этом Pro-карточка осталась акцентной (`highlighted`).
- Добавлены widget-тесты [paywall_visual_hierarchy_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/paywall/widget/paywall_visual_hierarchy_test.dart):
  - badge отображается на annual,
  - badge не рендерится без текста,
  - у Pro-card нет global badge,
  - Free-card в neutral-режиме рендерит muted check.
- Проверки:
  - `cd client && flutter test test/presentation/paywall/widget/paywall_visual_hierarchy_test.dart` (pass)
  - `cd client && flutter analyze` (pass)
