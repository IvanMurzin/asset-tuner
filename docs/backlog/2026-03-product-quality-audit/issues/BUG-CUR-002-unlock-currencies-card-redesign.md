# BUG-CUR-002: Обновить блок unlock more currencies на Base Currency screen

## Метаданные
- ID: `BUG-CUR-002`
- Тип: `Bug`
- Приоритет: `P2`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-003`, `FTR-009`, `SCR-012`, `SCR-013`

## Экран/модуль/слой
- Экраны: Base Currency, Paywall entry point
- Слой: `presentation`

## Проблема
### Текущее поведение
Unlock-card недостаточно выразительна и не формирует понятный action к апгрейду.

### Ожидаемое поведение
Карточка с четким заголовком, коротким value-prop и action (“Перейти в Pro”), визуально отличающаяся от обычных блоков.

## Root-cause hypothesis
Текущий `DSUnlockCurrenciesCard` недостаточно информативен.

## Предлагаемое решение
1. Переработать copy + visual emphasis.
2. Добавить action text/button внутри карточки.
3. Сохранить единый переход в paywall с reason `base_currency`.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given free-пользователь, when открывает base currency screen, then видит понятный unlock блок.
2. Given tap по action, when выполняется переход, then открывается paywall с корректным reason.

## Тест-сценарии
### Manual
1. Проверить free/pro отображение.

### Auto
1. Widget test видимости блока по плану.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не дублировать/конфликтовать с отдельными paywall баннерами.

## Ссылки на текущую реализацию
- [ds_unlock_currencies_card.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_unlock_currencies_card.dart)

## Implementation note
- Переработан visual/copy unlock-карточки на экране Base Currency:
  - [ds_unlock_currencies_card.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_unlock_currencies_card.dart)
  - [base_currency_settings_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/settings/page/base_currency_settings_page.dart)
- В карточку добавлены:
  - выразительный заголовок (`paywallFeatureCurrencies`),
  - короткий value-prop (`baseCurrencySettingsPaywallHint`),
  - явный action-chip (`paywallUpgrade`).
- Сохранён единый переход в paywall с reason `base_currency`.
- Добавлен widget-тест free-сценария: видимость unlock-card и переход по action c `PaywallReason.baseCurrency`.
  - [base_currency_settings_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/settings/page/base_currency_settings_page_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/settings/page/base_currency_settings_page_test.dart` (pass)
- Пропущено:
  - `cd client && flutter test` (не запускался; для задачи выполнен целевой widget-тест + обязательный analyze).
