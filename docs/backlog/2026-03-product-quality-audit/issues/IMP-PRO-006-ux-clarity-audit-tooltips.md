# IMP-PRO-006: Провести UX clarity audit и точечно добавить tooltips/captions

## Метаданные
- ID: `IMP-PRO-006`
- Тип: `Improvement`
- Приоритет: `P2`
- Статус: `Draft`
- Связанные FR/FTR/SCR: `FTR-002`, `FTR-008`, `FTR-010`, `SCR-004`, `SCR-017`

## Экран/модуль/слой
- Сквозной UX audit
- Слой: `presentation`

## Проблема
### Текущее поведение
На части экранов пользователь не получает достаточного контекста, но при этом есть риск перегрузить интерфейс избыточными подсказками.

### Ожидаемое поведение
Точечные подсказки в high-impact местах, без объяснения каждого элемента.

## Root-cause hypothesis
Отсутствует системный audit по понятности и приоритетным точкам обучения.

## Предлагаемое решение
1. Сформировать карту UX friction points.
2. Добавить ограниченное число caption/tooltip с четкой пользой.
3. Определить принципы “где не добавлять подсказки”.

## Изменения API/контрактов/конфига
- Нет.

## Acceptance Criteria
1. Given ключевые экраны, when пользователь впервые видит сложный блок, then доступна краткая подсказка.
2. Given повторное использование экрана, when пользователь опытный, then интерфейс не перегружен.

## Тест-сценарии
### Manual
1. UX walkthrough по основным user journeys.

### Auto
1. N/A (кроме smoke на отсутствие layout regressions).

## Зависимости и блокеры
- Желательно после стабилизации `SUB/CUR` flows.

## Риски и anti-regression
- Не превратить приложение в “tutorial over UI”.

## Ссылки на текущую реализацию
- [screen_map.md](/Users/ivanmurzin/Projects/pets/asset_tuner/docs/ux/screen_map.md)
- [user_journeys.md](/Users/ivanmurzin/Projects/pets/asset_tuner/docs/ux/user_journeys.md)
