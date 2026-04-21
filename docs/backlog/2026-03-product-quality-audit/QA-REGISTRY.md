# Product Quality Audit - Unified QA Registry

Single registry for backlog iterations done by `$iterate-backlog`.

## Entry Template

### <YYYY-MM-DD HH:MM TZ> - <ISSUE-ID> - <Done|Blocked>
- Commit: `<hash>`
- Changed files:
  - `<path>`
- Auto checks:
  - `<command>` -> `<pass|fail|not executed>`
- Manual QA checklist:
  - [ ] `<step 1>`
  - [ ] `<step 2>`
- Notes:
  - `<risk/observation>`

For blocked tasks, replace manual QA checklist with unblock steps:
- Unblock steps:
  - `<action 1>`
  - `<action 2>`
- Blocked reason:
  - `<clear blocking reason>`

---

## Entries

### 2026-04-21 18:23 +04 - BUG-ANA-001 - Done
- Commit: `HEAD`
- Changed files:
  - `backend/supabase/functions/api/index.ts`
  - `backend/supabase/migrations/20260421183000_api_analytics_summary.sql`
  - `client/lib/core/supabase/supabase_constants.dart`
  - `client/lib/data/analytics/data_source/supabase_analytics_data_source.dart`
  - `client/lib/data/analytics/dto/analytics_summary_dto.dart`
  - `client/lib/data/analytics/mapper/analytics_summary_mapper.dart`
  - `client/lib/data/analytics/repository/analytics_repository.dart`
  - `client/lib/domain/analytics/entity/analytics_summary_entity.dart`
  - `client/lib/domain/analytics/repository/i_analytics_repository.dart`
  - `client/lib/domain/analytics/usecase/get_analytics_summary_usecase.dart`
  - `client/lib/presentation/analytics/bloc/analytics_cubit.dart`
  - `client/test/presentation/analytics/bloc/analytics_cubit_test.dart`
  - `docs/contracts/api_surface.md`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-ANA-001-backend-analytics-endpoint.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/analytics/bloc/analytics_cubit_test.dart` -> `pass`
  - `cd backend && deno check supabase/functions/api/index.ts` -> `not executed (environment limitation: deno not installed)`
  - `cd backend && ./scripts/deploy_supabase.sh --help` -> `not executed (unsafe in this environment: command performs real remote deploy/migrations)`
- Manual QA checklist:
  - [ ] Открыть Analytics при непустых аккаунтах и убедиться, что данные загружаются через единый endpoint без каскада history-запросов с клиента.
  - [ ] Обновить баланс счёта, затем сделать pull-to-refresh в Analytics и проверить, что breakdown/updates отражают изменения.
  - [ ] Смоделировать ошибку `GET /api/analytics/summary` и проверить retryable error state с рабочей кнопкой повторной загрузки.
- Notes:
  - Клиентский fan-out удалён из `AnalyticsCubit`; агрегация перенесена в backend RPC `api_analytics_summary`.

### 2026-04-21 18:11 +04 - IMP-PRO-006 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/overview/page/overview_page.dart`
  - `client/lib/presentation/overview/widget/overview_summary_card.dart`
  - `client/lib/presentation/analytics/page/analytics_page.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/test/presentation/analytics/page/analytics_page_test.dart`
  - `client/test/presentation/overview/widget/overview_summary_card_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/IMP-PRO-006-ux-clarity-audit-tooltips.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter test test/presentation/analytics/page/analytics_page_test.dart` -> `pass`
  - `cd client && flutter test test/presentation/overview/widget/overview_summary_card_test.dart` -> `pass`
  - `cd client && flutter analyze` -> `pass`
- Manual QA checklist:
  - [ ] Открыть `SCR-004` и проверить tooltip на chip базовой валюты (long-press / hover) и caption под карточкой итога.
  - [ ] Открыть `SCR-017` и проверить, что у секций `Breakdown` и `Updates` отображаются лаконичные поясняющие captions.
  - [ ] Переключить locale `en/ru` и подтвердить корректную локализацию всех новых подсказок без переполнения layout.
- Notes:
  - Добавлены только high-impact подсказки; поэлементные tooltips внутри breakdown/updates не добавлялись, чтобы избежать визуальной перегрузки.

### 2026-04-21 18:00 +04 - BUG-PRO-005 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/paywall/page/paywall_page.dart`
  - `client/lib/presentation/paywall/widget/paywall_plan_toggle.dart`
  - `client/lib/presentation/paywall/widget/paywall_tier_card.dart`
  - `client/test/presentation/paywall/widget/paywall_visual_hierarchy_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-PRO-005-paywall-visual-redesign.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter test test/presentation/paywall/widget/paywall_visual_hierarchy_test.dart` -> `pass`
  - `cd client && flutter analyze` -> `pass`
- Manual QA checklist:
  - [ ] Открыть paywall и проверить, что badge `Most popular` отображается только на annual plan option.
  - [ ] Проверить, что у секции Pro отсутствует global badge и она остаётся визуально акцентной.
  - [ ] Проверить, что у секции Free нейтральный серый стиль и переключение monthly/annual не ломает purchase flow.
- Notes:
  - Изменения ограничены `presentation/paywall` и widget-тестами; purchase/restore логика не изменялась.

### 2026-04-21 17:53 +04 - BUG-PRO-004 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/lib/presentation/profile/page/archived_accounts_page.dart`
  - `client/test/presentation/profile/page/archived_accounts_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-PRO-004-archived-screen-description.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/profile/page/archived_accounts_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Открыть `Archived accounts` и проверить, что под заголовком отображается пояснение про исключение архивных счетов из общего баланса.
  - [ ] Проверить экран archived при непустом и пустом списке: caption виден и не ломает layout.
  - [ ] Переключить locale `en/ru` и подтвердить корректную локализацию caption.
- Notes:
  - Изменения ограничены archived-экраном и l10n; бизнес-логика расчета totals не затронута.

### 2026-04-21 17:19 +04 - BUG-PRO-002 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/profile/page/archived_accounts_page.dart`
  - `client/test/presentation/profile/page/archived_accounts_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-PRO-002-archived-list-card-parity.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/profile/page/archived_accounts_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить экран Archived accounts: в карточке отображаются имя аккаунта, сумма и количество счетов.
  - [ ] Сверить populated archived-card с main-card по составу полей (без упрощённых заглушек).
  - [ ] Проверить визуальный archived-state: карточки на archived-экране отображаются с пониженной opacity.
- Notes:
  - Archived-карточки используют те же данные `totals/subaccountsCount`, но остаются визуально ослабленными через `Opacity(0.64)`.

### 2026-04-17 19:46 +04 - BUG-PRO-001 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/profile/page/profile_page.dart`
  - `client/lib/core/routing/app_router.dart`
  - `client/lib/core/routing/app_routes.dart`
  - `client/lib/presentation/profile/page/account_actions_page.dart` (deleted)
  - `client/test/presentation/profile/page/profile_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-PRO-001-move-account-actions-into-profile.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/profile/page/profile_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить `SCR-009`: внизу `Profile` видны действия `Sign out` и `Delete account` без перехода на отдельный экран.
  - [ ] Нажать `Sign out` на Profile и подтвердить переход на `sign-in`.
  - [ ] Нажать `Delete account` на Profile: confirm-dialog отображается, cancel/confirm работают корректно.
- Notes:
  - Удалён nested route `/profile/account`; account actions теперь встроены в `ProfilePage`.

### 2026-04-17 19:35 +04 - BUG-PRO-003 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/profile/page/archived_accounts_page.dart`
  - `client/test/presentation/profile/page/archived_accounts_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-PRO-003-archived-navigation-backstack-fix.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/profile/page/archived_accounts_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить flow `Profile -> Archived accounts -> Account detail -> Back`: возврат всегда в archived list.
  - [ ] Проверить deep link на `/main/accounts/:accountId`: back ведет согласно текущему стеку и не редиректит принудительно в archived.
  - [ ] Проверить обычный переход из main accounts в detail: поведение back не изменилось.
- Notes:
  - Изменение локализовано в archived-flow (замена `go` на `push`), остальные точки входа в `AccountDetailPage` не затронуты.

### 2026-04-17 19:28 +04 - BUG-SUB-007 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/balance/widget/subaccount_history_section.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/test/presentation/balance/page/subaccount_detail_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-007-subaccount-history-copy-update.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/balance/page/subaccount_detail_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить `SCR-010` в `en`: заголовок секции равен `Your balance history`, подпись объясняет изменения после snapshot update.
  - [ ] Проверить `SCR-010` в `ru`: заголовок секции равен `История баланса счёта`, подпись корректно локализована и использует термин `счёт`.
  - [ ] Проверить оба состояния секции (пустая история и список записей): новый copy отображается и не ломает layout.
- Notes:
  - Ключи `positionHistoryTitle` и `positionHistoryDescription` обновлены/добавлены без переименования существующих l10n-идентификаторов.

### 2026-04-17 19:20 +04 - BUG-SUB-005 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/account/widget/account_detail_positions_section.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/test/presentation/account/widget/account_detail_positions_section_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-005-account-detail-subaccounts-caption.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/account/widget/account_detail_positions_section_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить `SCR-007` с непустым списком счётов: caption под заголовком секции отображается и не ломает layout карточек.
  - [ ] Проверить `SCR-007` с пустым списком счётов: caption отображается вместе с empty-state и CTA.
  - [ ] Переключить locale `en/ru` и подтвердить корректную локализацию caption.
- Notes:
  - Перегенерация `app_localizations_*` синхронизировала существующие ARB-правки терминологии по счетам, добавленные в предыдущих итерациях.

### 2026-04-17 19:12 +04 - BUG-SUB-008 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/presentation/balance/page/add_balance_page.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/test/presentation/balance/page/add_balance_page_test.dart`
  - `client/test/presentation/balance/page/subaccount_detail_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-008-rename-update-balance-to-set-balance.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/balance/page/add_balance_page_test.dart` -> `pass`
  - `cd client && flutter test test/presentation/balance/page/subaccount_detail_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить `SCR-010`: action label отображает `Set balance` / `Установить баланс`.
  - [ ] Проверить `SCR-011`: title отображает `Set balance` / `Установить баланс`.
  - [ ] Проверить `SCR-011` в `en/ru`: helper явно объясняет, что задается новое текущее значение баланса.
- Notes:
  - Route-имя `update-balance` не менялось (технический identifier сохранен).

### 2026-04-17 19:06 +04 - IMP-SUB-004 - Done
- Commit: `HEAD`
- Changed files:
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_en.arb`
  - `docs/backlog/2026-03-product-quality-audit/issues/IMP-SUB-004-terminology-consistency-ru-en.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
  - `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
- Manual QA checklist:
  - [ ] Проверить `SCR-007`/`SCR-008`/`SCR-010` в locale `ru`: во всех subaccount-экранах используется термин «счёт» без «суб-аккаунт».
  - [ ] Проверить те же сценарии в locale `en`: используется единая форма «subaccount» (без `sub-account`).
  - [ ] Проверить paywall copy для лимита subaccounts в `ru/en`.
- Notes:
  - Изменения ограничены ARB copy и backlog-документацией; ключи локализации не переименовывались.

### 2026-04-17 19:01 +04 - IMP-SUB-003 - Done
- Commit: `199f508`
- Changed files:
  - `client/lib/presentation/account/page/add_subaccount_context.dart`
  - `client/lib/presentation/account/page/add_subaccount_page.dart`
  - `client/lib/l10n/app_en.arb`
  - `client/lib/l10n/app_ru.arb`
  - `client/lib/l10n/app_localizations.dart`
  - `client/lib/l10n/app_localizations_en.dart`
  - `client/lib/l10n/app_localizations_ru.dart`
  - `client/test/presentation/account/page/add_subaccount_page_test.dart`
  - `client/test/presentation/account/page/add_subaccount_context_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/IMP-SUB-003-contextual-hints-defaults-by-account-type.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/account/page/add_subaccount_page_test.dart` -> `pass`
  - `cd client && flutter test test/presentation/account/page/add_subaccount_context_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить Add subaccount для `bank`/`wallet`/`exchange`/`cash`/`other` и убедиться, что hints/helpers меняются по типу аккаунта.
  - [ ] Переключить locale `en`/`ru` и проверить консистентность терминов и контекстных описаний.
  - [ ] Проверить, что default currency выбирается по expected kind и locked assets не выбираются по умолчанию.
- Notes:
  - Поведение prefill amount не изменено: поле суммы стартует пустым, значение `0` остаётся валидным для сабмита.

### 2026-04-17 17:58 +04 - BUG-SUB-010 - Done
- Commit: `e11eaab`
- Changed files:
  - `backend/supabase/migrations/20260417173000_api_set_subaccount_balance_reject_unchanged.sql`
  - `client/lib/core/supabase/supabase_failure_mapper.dart`
  - `client/lib/l10n/supabase_error_localization_en.dart`
  - `client/lib/l10n/supabase_error_localization_ru.dart`
  - `client/lib/presentation/analytics/bloc/analytics_cubit.dart`
  - `client/lib/presentation/balance/bloc/subaccount_info_cubit.dart`
  - `client/test/core/supabase/supabase_failure_mapper_test.dart`
  - `client/test/presentation/analytics/bloc/analytics_cubit_test.dart`
  - `client/test/presentation/balance/bloc/subaccount_info_cubit_test.dart`
  - `docs/contracts/api_surface.md`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-010-block-zero-delta-updates.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/core/supabase/supabase_failure_mapper_test.dart` -> `pass`
  - `cd client && flutter test test/presentation/balance/bloc/subaccount_info_cubit_test.dart` -> `pass`
  - `cd client && flutter test test/presentation/analytics/bloc/analytics_cubit_test.dart` -> `pass`
  - `cd backend && ./scripts/deploy_supabase.sh --help` -> `pass (with warnings on remote seed DNS step)`
- Manual QA checklist:
  - [ ] Повторить Set balance тем же значением и проверить показ локализованной ошибки без сохранения новой записи.
  - [ ] Проверить, что в Subaccount history не отображаются legacy записи с нулевым diff.
  - [ ] Проверить, что в Analytics/Updates отсутствуют zero-delta изменения.
- Notes:
  - Скрипт backend quality-check при вызове с `--help` фактически выполнил deploy/migration на remote Supabase проект.

### 2026-04-17 17:02 +04 - BUG-SUB-009 - Done
- Commit: `748ee1c`
- Changed files:
  - `client/lib/presentation/balance/page/add_balance_page.dart`
  - `client/test/presentation/balance/page/add_balance_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-009-set-balance-prefill-and-locked-currency.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/balance/page/add_balance_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Открыть Set balance для субаккаунта с ненулевым балансом и проверить prefill суммы.
  - [ ] Нажать на валютный badge в Set balance и убедиться, что смена валюты недоступна.
- Notes:
  - Значение amount берётся из актуального текущего баланса (`entries.first.snapshotAmount` или fallback на `subaccount.currentAmount`).

### 2026-04-17 16:41 +04 - BUG-SUB-006 - Done
- Commit: `ae20815`
- Changed files:
  - `client/lib/presentation/balance/page/subaccount_detail_page.dart`
  - `client/lib/presentation/balance/widget/subaccount_history_section.dart`
  - `client/test/presentation/balance/page/subaccount_detail_page_test.dart`
  - `docs/backlog/2026-03-product-quality-audit/issues/BUG-SUB-006-subaccount-detail-full-scroll-and-refresh.md`
  - `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Auto checks:
  - `cd client && flutter analyze` -> `pass`
  - `cd client && flutter test test/presentation/balance/page/subaccount_detail_page_test.dart` -> `pass`
- Manual QA checklist:
  - [ ] Проверить длинную history на реальном устройстве (iOS/Android).
  - [ ] Проверить pull-to-refresh: не срабатывает вне top и срабатывает из top.
- Notes:
  - Удалён nested scroll на detail-экране; скролл и refresh перенесены на единый root list.
  - Пагинация history (`onLoadMore`) сохранена без изменения контракта cubit.
