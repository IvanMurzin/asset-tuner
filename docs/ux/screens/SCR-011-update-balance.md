# SCR-011: Update balance (snapshot-only) — MVP v2

See also: `docs/contracts/api_surface.md` (`POST /update_subaccount_balance`).

## Purpose
Create a **snapshot** balance entry for a subaccount (счёт) for **today**.

## Layout sections
- App bar
  - Title: “Update balance”
  - Close/back
- Form card
  - Date: today (read-only)
  - Amount input (Decimal)
  - Helper text (what snapshot means)
- Footer
  - Primary CTA: “Save”

## Components
- DS: `DSButton`
- DS: `DSCard`
- needs component: `DSAppBar`
- needs component: `DSDecimalField` (Decimal-safe input + locale separators)
- needs component: `DSInlineBanner` (network errors)

## Actions & navigation
- Save:
  - Validate:
    - amount present and valid decimal
  - Submit to backend “update subaccount balance” operation:
    - send `snapshot_amount` and `entry_date=today`
  - On success:
    - Close and return to `SCR-010` with refreshed data.

## States
- Default:
  - Date defaults to today.
- Loading:
  - Saving; disable form; show loading on CTA.
- Error:
  - Validation: inline field errors (highlight specific field).
  - Network: banner + retry.
- Success:
  - Entry created; history refresh.

## Copy (key text)
- Title: “Update balance”
- Date: “Date”
- Date value: “Today”
- Amount: “Amount”
- Helper: “A snapshot is your balance today.”
- Save: “Save”
- Validation (amount): “Enter an amount”
- Error (generic): “Couldn’t save. Try again.”

## Edge cases
- Multiple entries on same date:
  - Allowed in MVP v2. Ordering: `entry_date desc, created_at desc`.
- Offline:
  - Disable save and show “You’re offline. Changes are disabled.”
- Keyboard + safe area:
  - Tap outside input dismisses keyboard via DS input callback (`onTapOutside`).
