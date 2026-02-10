# SCR-005: Accounts list

## Purpose
Manage accounts: view active + archived accounts, create new, edit, archive/unarchive, and delete with confirmation.

## Layout sections
- App bar
  - Title: “Accounts”
  - Primary action: “Add” (create)
- Active accounts section
  - List of accounts
- Archived accounts section (collapsed/expanded)
  - Archived list + unarchive actions

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar` (title + add action)
- needs component: `DSListRow` (account row with subtitle type + overflow menu)
- needs component: `DSOverflowMenu` (Edit / Archive / Delete)
- needs component: `DSConfirmDialog` (archive/unarchive, delete)
- needs component: `DSEmptyState` (no accounts)
- needs component: `DSInlineBanner` (errors)

## Actions & navigation
- Add account → `SCR-006` (create).
- Tap account row → `SCR-007` (detail).
- Overflow actions:
  - Edit → `SCR-006` (edit).
  - Archive → confirm → moves to Archived.
  - Unarchive (from Archived section) → confirm → moves to Active.
  - Delete → confirm destructive → deletes account and dependent data.

## States
- Loading:
  - Fetching accounts list; show skeleton rows.
- Empty:
  - No accounts → show empty state with CTA “Create account”.
- Error:
  - Retry banner + “Try again”.
  - Delete/archive failures are inline per-account where possible (show which account failed).
- Success:
  - Active and archived sections render; actions update lists.

## Copy (key text)
- Title: “Accounts”
- Add: “Add account”
- Empty title: “No accounts yet”
- Empty body: “Create an account to start tracking assets.”
- Empty CTA: “Create account”
- Archived section title: “Archived”
- Archive confirm title: “Archive account?”
- Archive confirm body: “This account will be hidden from totals.”
- Archive confirm CTA: “Archive”
- Unarchive confirm title: “Unarchive account?”
- Unarchive CTA: “Unarchive”
- Delete confirm title: “Delete account?”
- Delete confirm body: “This will delete all assets and balance history in this account.”
- Delete confirm CTA: “Delete”
- Cancel: “Cancel”

## Edge cases
- Free tier account limit reached:
  - “Add account” entry points route to `SCR-006`, but saving is gated there with paywall (`SCR-013`).
- Archived accounts contributing to totals:
  - Must not contribute by default (ensure copy communicates this).

