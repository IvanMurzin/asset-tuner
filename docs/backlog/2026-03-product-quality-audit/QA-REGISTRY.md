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

