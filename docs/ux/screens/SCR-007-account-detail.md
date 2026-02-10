# SCR-007: Account detail

## Purpose
Show an account’s asset positions with their latest original amount and converted amount (when priced), and allow adding/removing assets.

## Layout sections
- App bar
  - Account name
  - Overflow actions: Edit / Archive / Delete
- Summary (optional)
  - Account total (converted)
  - Missing-rate indicator if any positions unpriced
- Asset positions list
  - Rows: asset code/name, latest original amount, converted amount or “Unpriced”
  - CTA: “Add asset” when list is empty or as primary action

## Components
- DS: `DSSectionTitle`
- DS: `DSCard`
- DS: `DSButton`
- needs component: `DSAppBar` (title + overflow)
- needs component: `DSOverflowMenu` (edit/archive/delete)
- needs component: `DSListRow` (asset position row)
- needs component: `DSConfirmDialog` (remove asset, archive, delete)
- needs component: `DSInlineBanner` (missing rates, errors, offline)
- needs component: `DSEmptyState` (no assets)

## Actions & navigation
- Tap asset position → `SCR-010` (Asset position detail).
- Add asset → `SCR-008`.
- Remove asset:
  - Via swipe or overflow per row (implementation choice).
  - Confirm removal; on success position disappears and totals update.
- Edit account → `SCR-006` (edit).
- Archive/unarchive/delete:
  - Confirmations required.
  - Delete calls server-side cascade delete.

## States
- Loading:
  - Fetching account + positions + latest balances; skeleton list.
- Empty:
  - No assets → show empty state with CTA “Add asset”.
- Error:
  - Retry banner.
  - Row-level errors for remove if possible.
- Success:
  - Show latest original amount and converted amount where priced.
  - Unpriced shows “Unpriced” indicator and excludes from priced totals.

## Copy (key text)
- Add asset: “Add asset”
- Empty title: “No assets in this account”
- Empty body: “Add the currencies or tokens you hold here.”
- Unpriced: “Unpriced”
- Remove confirm title: “Remove asset?”
- Remove confirm body: “This will remove the asset from this account.”
- Remove CTA: “Remove”
- Missing rates banner: “Some assets can’t be priced right now.”
- Offline banner: “Offline — changes are disabled.”

## Edge cases
- Remove asset with existing balance history:
  - Product decision required (delete history vs block). In MVP, show confirm text that clarifies what happens; if behavior is “block”, show guidance to delete history first.
- Archived account view:
  - If user opens an archived account, show a clear “Archived” badge/banner and offer “Unarchive”.

