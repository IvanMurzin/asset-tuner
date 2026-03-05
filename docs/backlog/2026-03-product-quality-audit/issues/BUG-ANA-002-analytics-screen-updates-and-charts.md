# BUG-ANA-002: Обновить Analytics screen (`Updates` -> `Balance snapshots`) и расширить графики

## Метаданные
- ID: `BUG-ANA-002`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-010`, `SCR-017`

## Экран/модуль/слой
- Экран: Analytics
- Слой: `presentation` + `l10n`

## Проблема
### Текущее поведение
Секция называется `Updates` и ограничена базовым набором визуализаций.

### Ожидаемое поведение
Секция переименована в `Balance snapshots`; экран показывает более полезные графики (например тренд total over time) на доступных данных.

## Root-cause hypothesis
UX/copy и визуализации отстают от текущего продуктового ожидания.

## Предлагаемое решение
1. Обновить копирайт и структуру секций analytics.
2. Добавить минимум один time-series график поверх новых backend-данных.
3. Сохранить fallback состояния loading/empty/error/offline.

## Изменения API/контрактов/конфига
- Может потребовать расширения payload analytics endpoint (`BUG-ANA-001`).

## Acceptance Criteria
1. Given analytics loaded, when экран рендерится, then секция называется `Balance snapshots`.
2. Given есть исторические данные, when открывается analytics, then отображается time-series график total.
3. Given данных мало/нет, when экран открыт, then корректно показываются empty/fallback состояния.

## Тест-сценарии
### Manual
1. Проверка нового copy и графиков.

### Auto
1. Widget tests секций analytics.

## Зависимости и блокеры
- Зависит от `BUG-ANA-001`.

## Риски и anti-regression
- Не перегрузить экран лишними графиками.

## Ссылки на текущую реализацию
- [analytics_page.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/presentation/analytics/page/analytics_page.dart)
- [app_en.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_en.arb)
- [app_ru.arb](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/l10n/app_ru.arb)
