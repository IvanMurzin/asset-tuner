# BUG-CUR-001: Переработать Base Currency screen (единая карточка + badge selector)

## Метаданные
- ID: `BUG-CUR-001`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
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

## Implementation note
- Переработан верхний блок выбора базовой валюты в единую карточку с inline badge-триггером:
  - [ds_base_currency_value_card.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_base_currency_value_card.dart)
  - [base_currency_settings_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/settings/page/base_currency_settings_page.dart)
- Экран переключен на новые copy-ключи карточки (`baseCurrencySettingsCurrentTitle`, `baseCurrencySettingsCurrentBody`) с более однозначным текстом для `en/ru`:
  - [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb)
  - [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb)
  - [app_localizations.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations.dart)
  - [app_localizations_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_en.dart)
  - [app_localizations_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_ru.dart)
- Добавлен widget-тест рендера карточки/badge и выбора валюты через badge selector:
  - [base_currency_settings_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/settings/page/base_currency_settings_page_test.dart)
- Проверки:
  - `cd client && flutter test test/presentation/settings/page/base_currency_settings_page_test.dart` (pass)
  - `cd client && flutter analyze` (pass)
- Пропущено:
  - `cd client && flutter test` (не запускался, так как для задачи достаточно целевого widget-теста + обязательного analyze).
