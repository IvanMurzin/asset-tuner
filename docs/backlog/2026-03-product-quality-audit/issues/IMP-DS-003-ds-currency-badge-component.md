# IMP-DS-003: Добавить компонент `DSCurrencyBadge`

## Метаданные
- ID: `IMP-DS-003`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-008`, `SCR-011`, `SCR-012`

## Экран/модуль/слой
- DS компонент для выбора/показа валюты
- Слой: `core_ui`

## Проблема
### Текущее поведение
Выбор валюты оформлен крупной карточкой `DSCurrencyPicker`, что перегружает формы и не соответствует target UX (компактный badge+dropdown).

### Ожидаемое поведение
Появляется компактный reusable компонент `DSCurrencyBadge` (код валюты + иконка dropdown + состояния enabled/disabled/locked).

## Root-cause hypothesis
Нет lightweight DS-примитива для inline currency selection.

## Предлагаемое решение
1. Создать `DSCurrencyBadge` в `core_ui/components`.
2. Поддержать state: `enabled`, `disabled`, `locked`, `selected`.
3. Использовать компонент в `DSBalanceInput`, base currency card и add subaccount.

## Изменения API/контрактов/конфига
- Новый DS компонент и его публичный API.

## Acceptance Criteria
1. Given форма с выбором валюты, when рендерится selector, then используется `DSCurrencyBadge`.
2. Given disabled state, when пользователь нажимает badge, then селектор не открывается.
3. Given locked валюту, when badge tapped, then вызывается paywall-handling callback.

## Тест-сценарии
### Manual
1. Проверка внешнего вида в light/dark/theme modes.

### Auto
1. Widget tests states + callbacks.

## Зависимости и блокеры
- Блокирует `IMP-DS-004`, `BUG-CUR-001`, `BUG-SUB-002`.

## Риски и anti-regression
- Не дублировать бизнес-логику paywall внутри DS; только UI callbacks.

## Ссылки на текущую реализацию
- [ds_currency_picker.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_currency_picker.dart)
