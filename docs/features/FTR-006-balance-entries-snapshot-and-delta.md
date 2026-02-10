# FTR-006: Balance entries (snapshot + delta) with history

## Summary
Let users record balance snapshots or delta adjustments for an asset position at any date, while ensuring snapshots compute and store an implied delta consistently across devices via an Edge Function.

Source references:
- Product: `docs/prd/prd.md` (snapshot vs delta; implied delta), `docs/prd/requirements.md` (FR-040..FR-045)
- Tech: `docs/tech/api_assumptions.md` (`balance_entries`, `POST /update_balance`), `docs/adr/ADR-0002-edge-functions-api.md`

## User story
As a user, I want to update my balances as a snapshot or as a change since last time, so that I can track how my total changes over time without full expense tracking.

## Scope / Out of scope
Scope:
- Entry modes:
  - Snapshot: “current balance is X”
  - Delta: “+X / −Y since last time”
- Any-date entry support (with UI optimized for monthly updates).
- Atomic backend write via Edge Function `POST /update_balance`:
  - On snapshot: compute implied delta vs previous snapshot and persist consistent history.
  - On delta: persist delta entry.
- Balance history view for an asset position (list; charts optional).
- Paginated history reads (page size 50; stable sort per `docs/tech/api_assumptions.md`).

Out of scope:
- Expense tracking and categorization (explicit non-goal; see `docs/prd/non_goals.md`).
- Editing historical entries (not specified; treat entries as immutable rows per `docs/tech/api_assumptions.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user opens “Add balance” for an asset position, when the form loads, then it allows selecting:
  - entry type (Snapshot or Delta),
  - entry date,
  - amount (Decimal input).
- Given the user submits a snapshot for date D, when the client calls `POST /update_balance` with `snapshot_amount`, then:
  - the server stores a new balance entry for date D,
  - the stored entry includes a computed implied delta vs the most recent prior snapshot (if any),
  - the client refreshes and displays the updated current balance and change history.
- Given the user submits a delta for date D, when the client calls `POST /update_balance` with `delta_amount`, then the server stores the delta entry and history reflects the change.
- Given multiple devices submit updates concurrently for the same asset position, when both sync, then the resulting history is consistent and does not duplicate snapshot logic (implied delta computed server-side only).
- Given the user views history for an asset position, when more than 50 entries exist, then the list is paginated and sorted by `entry_date desc, created_at desc`.
- Given the server returns a `validation` failure (e.g., missing amount, invalid date), when the app renders the error, then it highlights the invalid field and does not create an entry.

## UX references (which screens it touches; placeholders ok)
- Screen: Account detail → Asset position detail
- UI: “Add balance” modal/screen (snapshot vs delta toggle; date picker)
- Screen: Balance history list (per asset position)
- UI: Monthly update shortcut (e.g., “Update for this month”)

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
- `balance_entries` (user-owned; proposed shape)
  - `id: uuid`
  - `account_asset_id: uuid`
  - `entry_date: date` (or `timestamptz` if time-of-day matters; not required by PRD)
  - `entry_type: "snapshot" | "delta"`
  - `snapshot_amount: numeric` (nullable)
  - `delta_amount: numeric` (nullable)
  - `implied_delta_amount: numeric` (nullable; set when entry_type=snapshot)
  - `created_at: timestamptz`
- Edge Function:
  - `POST /update_balance { account_asset_id, entry_date, snapshot_amount? , delta_amount? }`
  - Response returns created/updated entry identifiers needed for refresh.

## Analytics (events, optional)
- `balance_entry_created { entry_type, asset_kind }`
- `balance_entry_create_failed { entry_type, failure_code }`
- `balance_history_viewed { account_asset_id }`

## Open questions (if any)
- Multiple entries on the same `entry_date`:
  - **MVP decision:** allowed.
  - Ordering: `entry_date desc, created_at desc` for history.
  - “Current balance” is computed by applying entries in chronological order (`entry_date asc, created_at asc`), where snapshots set the balance and deltas add/subtract.
