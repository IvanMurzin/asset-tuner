# FTR-006: Balance entries (snapshot-only) with history

## Summary
Let users record **snapshot-only** balance updates for a subaccount, while ensuring each snapshot stores a computed **diff** consistently across devices via an Edge Function.

Source references:
- Product: `docs/prd/prd.md` (snapshot vs delta; implied delta), `docs/prd/requirements.md` (FR-040..FR-045)
- Tech: `docs/tech/api_assumptions.md` (`balance_entries`, `POST /update_balance`), `docs/adr/ADR-0002-edge-functions-api.md`

## User story
As a user, I want to update my balances as a snapshot or as a change since last time, so that I can track how my total changes over time without full expense tracking.

## Scope / Out of scope
Scope:
- Entry mode:
  - Snapshot: “current balance is X (today)”
- Date defaults to today (any-date support can be added later).
- Atomic backend write via Edge Function `POST /update_subaccount_balance`:
  - Compute and store `diff_amount` vs previous snapshot (if any).
- Balance history view for a subaccount (list; charts optional).
- Paginated history reads (page size 50; stable sort per `docs/tech/api_assumptions.md`).

Out of scope:
- Expense tracking and categorization (explicit non-goal; see `docs/prd/non_goals.md`).
- Editing historical entries (not specified; treat entries as immutable rows per `docs/tech/api_assumptions.md`).
- Delta input in UI (explicitly deferred).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user opens “Update balance” for a subaccount, when the form loads, then it shows:
  - date = today (read-only in MVP v2),
  - amount input (required).
- Given the user submits a snapshot for date D, when the client calls `POST /update_subaccount_balance`, then:
  - the server stores a new snapshot entry for date D,
  - the stored entry includes a computed `diff_amount` vs the most recent prior snapshot (if any),
  - the client refreshes and displays the updated current balance and history.
- Given multiple devices submit snapshots concurrently for the same subaccount, when both sync, then the resulting history is consistent (diff computed server-side only).
- Given the user views history for a subaccount, when more than 50 entries exist, then the list is paginated and sorted by `entry_date desc, created_at desc`.
- Given the server returns a `validation` failure (e.g., missing amount, invalid date), when the app renders the error, then it highlights the invalid field and does not create an entry.

## UX references (which screens it touches; placeholders ok)
- Screen: Account detail → Subaccount detail
- UI: “Update balance” modal/screen (snapshot-only)
- Screen: Balance history list (per subaccount)

## States (loading/empty/error/success)
- Loading: submitting update; loading history pages.
- Empty:
  - No entries yet → show CTA “Add your first balance”.
- Error:
  - network (retry)
  - validation (inline form errors)
  - conflict (if server detects concurrency constraints; if used)
  - unknown (safe fallback)
- Success: entry created; totals/history refresh.

## Data needs (entities + fields)
- `balance_entries` (user-owned; v2 shape)
  - `id: uuid`
  - `subaccount_id: uuid`
  - `entry_date: date` (or `timestamptz` if time-of-day matters; not required by PRD)
  - `snapshot_amount: numeric` (non-null)
  - `diff_amount: numeric` (nullable; null when no previous snapshot)
  - `created_at: timestamptz`
- Edge Function:
  - `POST /update_subaccount_balance { subaccount_id, entry_date, snapshot_amount }`
  - Response returns created/updated entry identifiers needed for refresh.

## Analytics (events, optional)
- `balance_entry_created { entry_type, asset_kind }`
- `balance_entry_create_failed { entry_type, failure_code }`
- `balance_history_viewed { account_asset_id }`

## Open questions (if any)
- Multiple entries on the same `entry_date`:
  - **MVP v2 decision:** allowed.
  - Ordering: `entry_date desc, created_at desc` for history.
  - “Current balance” is the latest snapshot by the stable ordering `entry_date desc, created_at desc`.
