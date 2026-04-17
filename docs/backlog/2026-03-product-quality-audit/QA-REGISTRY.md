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

### 2026-04-17 19:01 +04 - IMP-SUB-003 - Done
- Commit: `pending (backlog(IMP-SUB-003))`
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
