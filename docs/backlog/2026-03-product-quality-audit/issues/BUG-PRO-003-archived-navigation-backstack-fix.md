# BUG-PRO-003: Исправить back-stack навигацию для archived account flow

## Метаданные
- ID: `BUG-PRO-003`
- Тип: `Bug`
- Приоритет: `P0`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `SCR-007`, `SCR-009`, `navigation`

## Экран/модуль/слой
- Flow: Archived Accounts -> Account Detail -> Back
- Слой: `routing/presentation`

## Проблема
### Текущее поведение
Из archived списка открытие detail выполняется через `context.go(...)`, из-за чего back ведет не всегда в ожидаемый archived список.

### Ожидаемое поведение
Использовать push/pop модель: detail открывается поверх archived list и back возвращает именно туда.

## Root-cause hypothesis
В [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart) используется `go` вместо `push`.

## Предлагаемое решение
1. Переключить навигацию archived->detail на `push`.
2. Проверить поведение `PopScope` и возвратных значений detail страниц.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given пользователь в archived list, when открывает detail и нажимает back, then возвращается в archived list.
2. Given deep link на detail, when back, then поведение корректно для текущего стека.

## Тест-сценарии
### Manual
1. Прогон перехода archived -> detail -> back.

### Auto
1. Navigation test stack behavior.

## Зависимости и блокеры
- Нет.

## Риски и anti-regression
- Не сломать main-account-detail navigation.

## Ссылки на текущую реализацию
- [archived_accounts_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/profile/page/archived_accounts_page.dart)
- [app_router.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core/routing/app_router.dart)
