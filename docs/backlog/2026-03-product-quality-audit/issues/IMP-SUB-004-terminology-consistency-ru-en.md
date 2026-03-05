# IMP-SUB-004: Консистентная терминология `счёт` (ru) и `subaccount` (en)

## Метаданные
- ID: `IMP-SUB-004`
- Тип: `Improvement`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-002`, `FTR-005`, `SCR-007`, `SCR-008`, `SCR-010`

## Экран/модуль/слой
- Локализация `l10n`
- Слой: `presentation/l10n`

## Проблема
### Текущее поведение
В `ru` и `en` встречается смешение терминов (`счет/аккаунт/суб-аккаунт`) без единого стандарта.

### Ожидаемое поведение
- `ru`: единообразно “счёт” в контексте subaccount.
- `en`: единообразно “subaccount”.

## Root-cause hypothesis
В ARB-файлах накопились разнородные строки из разных итераций.

## Предлагаемое решение
1. Провести l10n audit строк, связанных с subaccount.
2. Обновить ключи/значения без потери обратной совместимости где возможно.
3. Синхронизировать термины в UX docs.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given любой экран subaccount flow, when locale=ru, then используется термин “счёт”.
2. Given locale=en, when те же экраны, then используется “subaccount”.

## Тест-сценарии
### Manual
1. Пройти CRUD subaccount в двух локалях.

### Auto
1. L10n snapshot тесты ключевых экранов.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не сломать ссылки на ключи в сгенерированном l10n коде.

## Ссылки на текущую реализацию
- [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb)
- [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb)
