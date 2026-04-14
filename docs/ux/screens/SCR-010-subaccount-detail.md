# SCR-010: Subaccount detail (history) — MVP v2

See also: `docs/features/FTR-006-balance-entries-snapshot-and-delta.md`.

## Purpose
Show a subaccount (счёт) current balance and balance history, and allow updating balance (snapshot-only).

## Layout sections
- App bar
  - Subaccount name
  - Overflow actions: Rename / Delete
- Summary card (gradient)
  - Current balance (latest snapshot)
  - Converted value (base currency; placeholder if not priced)
  - “Rates updated at …”
- History list
  - Entries sorted by `entry_date desc, created_at desc`
  - Shows snapshot amount and diff (when available)
  - Pagination (“Load more” or infinite scroll)
- Primary CTA
  - “Update balance”

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar`
- needs component: `DSListRow` (history row)
- needs component: `DSSnackBar` (errors, offline)
- needs component: `DSEmptyState` (no history)
- needs component: `DSSkeleton` (loading)

## Actions & navigation
- Update balance → `SCR-011`.
- Rename:
  - Changes subaccount name only (currency is immutable).
- Delete:
  - Confirm destructive action.
  - On success: return to `SCR-007` (Account detail).
- Pagination:
  - Load next page (50 entries/page).

## States
- Loading:
  - Loading current balance + first page of history.
- Empty:
  - No entries → show CTA “Add your first balance”.
- Error:
  - Retry banner for history load failures.
- Success:
  - Current balance and list render.
  - Unpriced:
    - Show banner and hide converted value or show “Unpriced”.

## Copy (key text)
- Update balance: “Update balance”
- Empty title: “No balance history yet”
- Empty body: “Add a snapshot to start tracking.”
- Empty CTA: “Add your first balance”
 

## Edge cases
- Offline:
  - Allow viewing cached history if available; disable “Update balance”.
- Many decimals:
  - Display rounding rules must not alter stored precision.
