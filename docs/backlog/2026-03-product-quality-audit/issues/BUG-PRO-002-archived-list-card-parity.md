# BUG-PRO-002: В archived list показывать карточки уровня main с данными и opacity

## Метаданные
- ID: `BUG-PRO-002`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-004`, `SCR-007`, `SCR-009`

## Экран/модуль/слой
- Экран: Archived accounts
- Слой: `presentation`

## Проблема
### Текущее поведение
Archived список использует упрощенные карточки с `total=0` и `subaccountsCount=0`, не отражая реальную информацию.

### Ожидаемое поведение
Карточки архивных аккаунтов визуально соответствуют main-card, содержат реальные данные, но с сниженной opacity.

## Root-cause hypothesis
В [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart) данные подставляются как заглушка.

## Предлагаемое решение
1. Пересчитать totals/subaccounts для архивных аккаунтов аналогично main/account-detail.
2. Переиспользовать компонент карточки с визуальным archived-state.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given archived list, when экран открыт, then карточки содержат имя, баланс и число subaccounts.
2. Given archived card, when отображается, then применена сниженная opacity.

## Тест-сценарии
### Manual
1. Сравнить main-card и archived-card по составу полей.

### Auto
1. Widget tests populated archived card.

## Зависимости и блокеры
- Может зависеть от общих расчетов overview/account info.

## Риски и anti-regression
- Не включить архивные суммы в глобальный total.

## Ссылки на текущую реализацию
- [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart)
