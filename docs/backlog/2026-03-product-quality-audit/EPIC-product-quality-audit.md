# EPIC: Product Quality Audit (March 2026)

## Метаданные
- ID: `EPIC-2026-03-PRODUCT-QUALITY-AUDIT`
- Тип: `Improvement`
- Приоритет: `P0`
- Статус: `Draft`
- Язык: `ru`
- Связанные документы:
  - `docs/prd/prd.md`
  - `docs/prd/requirements.md`
  - `docs/features/index.md`
  - `docs/contracts/api_surface.md`
  - `docs/contracts/data_contract.md`
  - `docs/ux/screen_map.md`

## Контекст
Этот epic формализует единый backlog по UX-дефектам, архитектурным несоответствиям, проблемам производительности UI, копирайта и API-контрактов. Источник требований — consolidated bug-report владельца продукта.

Цель: подготовить decision-complete пакет задач для последующей реализации другим агентом/инженером без расхождений с текущим состоянием `client`/`backend`.

## Продуктовые цели
1. Повысить понятность и предсказуемость пользовательских сценариев (auth, balances, currencies, archives, analytics).
2. Устранить UX-блокеры ввода (keyboard overlap, scroll, dismiss keyboard).
3. Снизить клиентскую нагрузку в аналитике, сместив агрегацию на backend API.
4. Привести формулировки и термины к единому стандарту `en/ru`.
5. Сохранить соответствие текущей архитектуре (Flutter layered + Supabase edge/rpc).

## Scope
- Входит: задачи `BUG-*` и `IMP-*` из `issues/` этой папки.
- Не входит: непосредственная реализация кода и миграций в рамках текущего этапа.

## Ограничения и инварианты
1. Не противоречить `docs/contracts/*` и `docs/features/*`; при конфликте — отдельная задача на выравнивание.
2. Не вводить прямые клиентские обращения к внешним провайдерам (rates/analytics).
3. Сохранять архитектурные границы: `presentation` не зависит от `data`, DS в `core_ui`.
4. Любые новые флаги конфигурации документировать одновременно в `AppConfig` и `.config*.json`.

## Definition of Ready (для каждой issue)
1. Есть точный экран/маршрут (`SCR` + route path).
2. Есть наблюдаемая проблема и ожидаемое поведение.
3. Есть гипотеза причины на основе текущих файлов.
4. Есть проверяемые Acceptance Criteria (Given/When/Then).
5. Есть тест-сценарии и риски регрессии.

## Definition of Done (для каждого дочернего issue при реализации)
1. Изменения соответствуют AC и не ломают связанные сценарии.
2. Локализация покрыта для `en` и `ru`.
3. Контракты API/конфига синхронизированы с docs.
4. Добавлены или обновлены тесты (unit/widget/integration по необходимости).
5. Навигация и pull-to-refresh работают детерминированно.

## Приоритизация
- `P0`: блокирующие UX/данные/контракты (auth flow, keyboard, set balance, analytics API, config flags).
- `P1`: важные улучшения интерфейса и понятности.
- `P2`: полировка UX/copy и визуальные refinements.

## Зависимости между пакетами
1. `CONF` и `AUTH` блокируют часть UX сценариев входа.
2. `DS` блокирует `CUR` и `SUB` (новые shared компоненты для currency/balance input).
3. `ANA` зависит от backend API контракта и обновления клиента.
4. `PRO` зависит от `SUB`/`ACCOUNT` навигационных правок.

## Связанные файлы
- Индекс задач: `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Чеклист owner для auth config: `docs/backlog/2026-03-product-quality-audit/OWNER-CHECKLIST-auth-config.md`
- Детализированные задачи: `docs/backlog/2026-03-product-quality-audit/issues/*`
