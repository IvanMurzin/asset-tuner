# IMP-SUB-003: Контекстные hints и default currency по типу аккаунта

## Метаданные
- ID: `IMP-SUB-003`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `FTR-004`, `FTR-005`, `SCR-008`

## Экран/модуль/слой
- Экран: Add subaccount
- Слой: `presentation`

## Проблема
### Текущее поведение
Placeholder и helper тексты не учитывают тип родительского аккаунта (bank/wallet/exchange/cash/other).

### Ожидаемое поведение
Подсказки и default выбор валюты зависят от account type, повышая понятность формы.

## Root-cause hypothesis
Текущий экран не использует контекст `account.type` для генерации UX-текста и default селектов.

## Предлагаемое решение
1. Добавить mapping account type -> hints/copy/default asset-kind.
2. Добавить description под полями name/amount.
3. Для amount initial value поддержать ноль по умолчанию (если согласовано UX).

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given account type bank, when пользователь открывает форму, then hints отличаются от wallet/cash.
2. Given amount поле, when экран открыт, then пользователь видит понятное описание назначения поля.
3. Given locale en/ru, when hints отображаются, then терминология консистентна.

## Тест-сценарии
### Manual
1. Проверка каждого account type.

### Auto
1. Unit test mapping `AccountType -> hint/default`.

## Зависимости и блокеры
- Связано с `IMP-SUB-004`.

## Риски и anti-regression
- Не допустить жесткого хардкода, не покрытого локализацией.

## Ссылки на текущую реализацию
- [account_entity.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/domain/account/entity/account_entity.dart)
- [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart)

## Implementation note
- Добавлен контекстный helper [add_subaccount_context.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_context.dart), который маппит `AccountType` в `copy profile` и `preferred asset kind`, а также выбирает default currency с fallback на противоположный kind и фильтром locked assets.
- Экран [add_subaccount_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/account/page/add_subaccount_page.dart) переведён на helper:
  - default currency теперь резолвится через `AddSubaccountContext`,
  - `hintText` для name и description под полями name/amount зависят от `account.type`,
  - prefill суммы оставлен пустым (`TextEditingController()` без initial `0`).
- Добавлены новые локализационные ключи в [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb) и [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb) с последующей регенерацией [app_localizations.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations.dart), [app_localizations_en.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_en.dart), [app_localizations_ru.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_localizations_ru.dart).
- Добавлены/обновлены автотесты:
  - [add_subaccount_context_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_context_test.dart)
  - [add_subaccount_page_test.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/test/presentation/account/page/add_subaccount_page_test.dart)
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/presentation/account/page/add_subaccount_page_test.dart` (pass)
  - `cd client && flutter test test/presentation/account/page/add_subaccount_context_test.dart` (pass)
