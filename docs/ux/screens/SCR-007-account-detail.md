# SCR-007: Account detail (MVP v2)

## Purpose
Show an account total and its subaccounts (счета), and allow adding subaccounts and managing the account.

## Layout sections
- App bar
  - Account name
  - Overflow actions: Edit / Archive / Delete
- Summary
  - Gradient card with account total converted to base currency
  - Secondary line: base currency code and “Rates updated at …”
- Actions section
  - Primary: “Add subaccount”
  - Secondary: archive / delete / edit are in overflow menu (or can be duplicated as buttons)
- Subaccounts list
  - Cards/rows:
    - subaccount name,
    - asset code,
    - current balance (original),
    - converted value in base currency (if priced).

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar` (title + overflow)
- needs component: `DSOverflowMenu` (edit/archive/delete)
- needs component: `DSSubaccountCard` or `DSListRow` (subaccount row)
- needs component: `DSConfirmDialog` (delete subaccount, archive, delete)
- needs component: `DSInlineBanner` (errors, offline)
- needs component: `DSEmptyState` (no subaccounts)

## Actions & navigation
- Tap subaccount → `SCR-010` (Subaccount detail).
- Add subaccount → `SCR-008`.
- Delete subaccount:
  - Confirm deletion; on success it disappears and totals update.
- Edit account → `SCR-006` (edit).
- Archive/unarchive/delete:
  - Confirmations required.
  - Delete calls server-side cascade delete.

## States
- Loading:
  - Fetching account + subaccounts + latest balances; skeleton list.
- Empty:
  - No subaccounts → show empty state with CTA “Add subaccount”.
- Error:
  - Retry banner.
  - Row-level errors for delete if possible.
- Success:
  - Show latest original amount and converted amount where priced.
  - If a row cannot be priced, show converted placeholder; Analytics excludes such updates/holdings.

## Copy (key text)
- Add subaccount: “Add subaccount”
- Empty title: “No subaccounts yet”
- Empty body: “Add the holdings you have in this account.”
- Delete subaccount confirm title: “Delete subaccount?”
- Delete subaccount confirm body: “This will delete its balance history.”
- Delete subaccount CTA: “Delete”
- Offline banner: “Offline — changes are disabled.”

## Edge cases
- Archived account view:
  - If user opens an archived account, show a clear “Archived” badge/banner and offer “Unarchive”.
