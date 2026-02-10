# SCR-011: Add balance (snapshot/delta)

## Purpose
Create a balance entry for an asset position as either a snapshot (“current balance is X”) or delta (“+X/−Y since last time”) on a chosen date.

## Layout sections
- App bar
  - Title: “Add balance”
  - Close/back
- Form card
  - Entry type selector (Snapshot / Delta)
  - Date picker
  - Amount input (Decimal)
  - Optional helper text (what snapshot vs delta means)
- Footer
  - Primary CTA: “Save”

## Components
- DS: `DSButton`
- DS: `DSCard`
- needs component: `DSAppBar`
- needs component: `DSSegmentedControl` (snapshot vs delta)
- needs component: `DSDatePickerField`
- needs component: `DSDecimalField` (Decimal-safe input + locale separators)
- needs component: `DSInlineBanner` (network errors)

## Actions & navigation
- Save:
  - Validate:
    - entry type selected
    - date present and valid
    - amount present and valid decimal
  - Submit to backend “update balance” operation:
    - Snapshot: send `snapshot_amount`
    - Delta: send `delta_amount`
  - On success:
    - Close and return to `SCR-010` with refreshed data.

## States
- Default:
  - Entry type defaults to Snapshot (recommended).
- Loading:
  - Saving; disable form; show loading on CTA.
- Error:
  - Validation: inline field errors (highlight specific field).
  - Network: banner + retry.
- Success:
  - Entry created; history refresh.

## Copy (key text)
- Title: “Add balance”
- Type: “Entry type”
- Snapshot: “Snapshot”
- Delta: “Change”
- Date: “Date”
- Amount: “Amount”
- Helper (snapshot): “A snapshot is your balance on that date.”
- Helper (delta): “A change is how much it increased or decreased.”
- Save: “Save”
- Validation (amount): “Enter an amount”
- Validation (date): “Choose a date”
- Error (generic): “Couldn’t save. Try again.”

## Edge cases
- Multiple entries on same date:
  - If allowed, communicate ordering (latest wins) in UI; if not allowed, show validation error from server.
- Offline:
  - Disable save and show “You’re offline. Changes are disabled.”

