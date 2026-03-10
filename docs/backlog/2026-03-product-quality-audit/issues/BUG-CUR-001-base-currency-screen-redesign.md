# BUG-CUR-001: Переработать Base Currency screen (единая карточка + badge selector)

## Метаданные
- ID: `BUG-CUR-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-003`, `SCR-012`, `SCR-003`

## Экран/модуль/слой
- Экран: Base currency settings
- Слой: `presentation` + `core_ui`

## Проблема
### Текущее поведение
Экран разбит на несколько крупных секций; выбор валюты отделен от контекста и занимает много места.

### Ожидаемое поведение
Единая верхняя карточка: заголовок + короткое описание + компактный `DSCurrencyBadge`, по нажатию которого открывается selector.

## Root-cause hypothesis
Текущая структура в [base_currency_settings_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/settings/page/base_currency_settings_page.dart) строится вокруг `DSCurrencyPicker`, а не inline badge-паттерна.

## Предлагаемое решение
1. Перестроить layout: “Ваша базовая валюта” + explanatory text + badge.
2. Сохранить paywall gating для locked валют.
3. Обновить copy в `en/ru` без двусмысленности.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given пользователь открывает экран, when контент загружен, then текущая валюта отображается внутри верхней карточки.
2. Given пользователь нажимает badge, when selector открывается, then можно выбрать валюту по текущим entitlements.
3. Given сохранение прошло, when пользователь возвращается на Main, then totals пересчитываются.

## Тест-сценарии
### Manual
1. Free vs Pro для выбора валют.
2. Проверка текста на `en/ru`.

### Auto
1. Widget тест рендера карточки и badge.

## Зависимости и блокеры
- Зависит от `IMP-DS-003`.

## Риски и anti-regression
- Не нарушить текущую логику `ProfileCubit.updateBaseCurrency`.

## Ссылки на текущую реализацию
- [base_currency_settings_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/settings/page/base_currency_settings_page.dart)
