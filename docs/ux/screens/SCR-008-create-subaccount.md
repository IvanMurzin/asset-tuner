# SCR-008: Create subaccount (MVP v2)

## Purpose
Create a new subaccount (счёт) inside an account by selecting a currency/token and entering a user-defined name and initial balance (snapshot for today).

## Layout sections
- App bar
  - Title: “Add subaccount”
  - Close/back
- Form
  - Subaccount name (required)
  - Asset picker (required; search catalog)
  - Initial balance (required; numeric/decimal)
  - Date: today (read-only in MVP v2)
- Footer
  - Primary CTA: “Add”
  - Secondary CTA: “Cancel”

## Components
- DS: `DSTextField` (name)
- DS: `DSSearchField` + list (asset picker)
- DS: `DSDecimalField` (balance)
- DS: `DSButton` (Add/Cancel)
- DS: `DSInlineBanner` (errors)
- DS: `DSSkeleton` (loading catalog)

## Actions & navigation
- Add:
  - Validate:
    - name required (non-empty trimmed)
    - asset required
    - balance required (can be `0`)
  - Submit to `POST /create_subaccount` (see `docs/contracts/api_surface.md`)
  - On success: return to `SCR-007` (Account detail) and show the new subaccount in the list.
- Cancel/back: return to `SCR-007` without changes.

## States
- Loading:
  - loading asset catalog
  - saving (disable controls, show loading on CTA)
- Error:
  - validation inline (name/asset/balance)
  - network/unauthorized/unknown with retry
- Success:
  - created; close the screen

## Copy (key text)
- Title: “Add subaccount”
- Name label: “Name”
- Asset label: “Currency”
- Balance label: “Balance”
- Date label: “Date”
- Date value: “Today”
- CTA: “Add”
- Cancel: “Cancel”
- Validation: “Name is required”, “Choose a currency”, “Enter a balance”
