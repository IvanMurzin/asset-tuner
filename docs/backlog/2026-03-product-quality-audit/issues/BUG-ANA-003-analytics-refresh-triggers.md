# BUG-ANA-003: Уточнить и стабилизировать refresh-триггеры аналитики

## Метаданные
- ID: `BUG-ANA-003`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-010`, `SCR-017`

## Экран/модуль/слой
- Экран: Analytics
- Слой: `presentation state orchestration`

## Проблема
### Текущее поведение
Refresh аналитики завязан на несколько источников, но нет явного списка событий и гарантии консистентности после изменений account/subaccount/balance.

### Ожидаемое поведение
Определен и реализован детерминированный набор триггеров refresh аналитики после mutating операций.

## Root-cause hypothesis
Текущая orchestration разбросана между cubit’ами и shell-уровнем.

## Предлагаемое решение
1. Зафиксировать trigger-matrix:
   - account create/update/archive/delete,
   - subaccount create/update/delete,
   - set balance success.
2. Централизовать invalidate+refresh механику.

## Изменения API/контрактов/конфига
- Нет внешних.

## Acceptance Criteria
1. Given любая mutation из trigger-matrix, when операция успешна, then analytics cache invalidated и перезагружен.
2. Given no relevant changes, when пользователь открывает analytics, then лишний refresh не выполняется.

## Тест-сценарии
### Manual
1. Проверить обновление analytics после каждой mutation.

### Auto
1. Unit tests на invalidate logic/fingerprint.

## Зависимости и блокеры
- Желательно после `BUG-ANA-001`.

## Риски и anti-regression
- Не увеличить число сетевых запросов сверх необходимого.

## Ссылки на текущую реализацию
- [analytics_cubit.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/bloc/analytics_cubit.dart)
- [main_shell_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/home/page/main_shell_page.dart)
