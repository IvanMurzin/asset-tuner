# SCR-010: Asset position detail (history)

## Purpose
Show the selected asset position’s current balance and balance history, and allow adding a new balance entry.

## Layout sections
- App bar
  - Asset code + account name (or asset name)
- Summary card
  - Current balance (derived per product rule)
  - Converted value (if priced) or “Unpriced”
- History list
  - Entries sorted by `entry_date desc, created_at desc`
  - Shows snapshot/delta type and implied delta (for snapshots)
  - Pagination (“Load more” or infinite scroll)
- Primary CTA
  - “Add balance”
  - Optional shortcut: “Update for this month”

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar`
- needs component: `DSListRow` (history row)
- needs component: `DSInlineBanner` (unpriced, offline)
- needs component: `DSEmptyState` (no history)
- needs component: `DSSkeleton` (loading)

## Actions & navigation
- Add balance → `SCR-011`.
- Monthly shortcut:
  - Prefills date as current month (implementation detail) and opens `SCR-011`.
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
- Add balance: “Add balance”
- Monthly: “Update for this month”
- Empty title: “No balance history yet”
- Empty body: “Add a snapshot or change to start tracking.”
- Empty CTA: “Add your first balance”
- Unpriced: “Unpriced”

## Edge cases
- Offline:
  - Allow viewing cached history if available; disable “Add balance”.
- Many decimals:
  - Display rounding rules must not alter stored precision.

