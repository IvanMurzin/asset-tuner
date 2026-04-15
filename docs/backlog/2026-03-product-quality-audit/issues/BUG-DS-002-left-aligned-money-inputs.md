# BUG-DS-002: Привести денежные input к вводу слева

## Метаданные
- ID: `BUG-DS-002`
- Тип: `Bug`
- Приоритет: `P1`
- Статус: `Done`
- Связанные FR/FTR/SCR: `SCR-008`, `SCR-011`, `SCR-010`

## Экран/модуль/слой
- Денежные поля во всех формах
- Слой: `core_ui/components`

## Проблема
### Текущее поведение
`DSDecimalField` использует `textAlign: TextAlign.end`, из-за чего сумма вводится справа.

### Ожидаемое поведение
По умолчанию баланс/amount вводится слева, как стандартный текстовый ввод.

## Root-cause hypothesis
Правило выравнивания захардкожено в [ds_decimal_field.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_decimal_field.dart).

## Предлагаемое решение
1. Изменить default align для `DSDecimalField` на `start`.
2. Пройтись по всем usage и убрать локальные overrides на right-align.

## Изменения API/контрактов/конфига
- Публичный DS API может получить опциональный параметр `textAlign` для совместимости.

## Acceptance Criteria
1. Given экран ввода суммы, when пользователь печатает, then текст идет слева.
2. Given существующие формы, when они рендерятся, then визуально нет регрессии в layout.

## Тест-сценарии
### Manual
1. Add subaccount / Set balance / другие amount поля.

### Auto
1. Widget test для default `textAlign`.

## Зависимости и блокеры
- Связано с `IMP-DS-004`.

## Риски и anti-regression
- Не сломать locale-aware parsing чисел.

## Ссылки на текущую реализацию
- [ds_decimal_field.dart](/Users/ivanmurzin/Projects/pets/asset_tuner/client/lib/core_ui/components/ds_decimal_field.dart)

## Implementation note
- Что сделано:
  - В `DSDecimalField` дефолтное выравнивание изменено с `TextAlign.end` на `TextAlign.start`.
  - Публичный API `DSDecimalField` расширен опциональным параметром `textAlign` для обратной совместимости и точечной настройки.
  - Добавлен widget test на дефолтный left align и на явный override align.
  - Проверены usage `DSDecimalField`: локальные `textAlign` overrides в приложении отсутствуют.
- Измененные файлы:
  - `client/lib/core_ui/components/ds_decimal_field.dart`
  - `client/test/core_ui/components/ds_decimal_field_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-DS-002-left-aligned-money-inputs.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Проверки:
  - `cd client && flutter analyze` (pass)
  - `cd client && flutter test test/core_ui/components/ds_decimal_field_test.dart` (pass)
