# SCR-006: Account form (create/edit)

## Purpose
Create a new account or edit an existing account’s name/type.

## Layout sections
- App bar
  - Title: “New account” or “Edit account”
  - Close/back
- Form
  - Account name input
  - Account type selector (Bank / Wallet / Exchange / Cash / Other)
  - Optional: type preview (small gradient/icon preview that matches the cards on Main)
- Footer
  - Primary CTA: “Save”
  - Secondary CTA: “Cancel” (optional; back also works)

## Components
- DS: `DSTextField` (name)
- DS: `DSButton`
- DS: `DSCard`
- needs component: `DSAppBar`
- needs component: `DSSegmentedControl` or `DSRadioGroup` (account type)
- needs component: `DSInlineBanner` (errors, paywall explanation)

## Actions & navigation
- Save:
  - Validate:
    - name required (non-empty trimmed)
    - type required
  - If creating and free-tier would exceed max accounts:
    - block save and show `SCR-013` paywall (reason “accounts limit”)
  - Otherwise submit create/edit.
  - On success:
    - Navigate to `SCR-007` (Account detail) or back to `SCR-004` (Main) depending on entry point.
- Cancel/back:
  - If changes exist, optionally confirm discard (nice-to-have; can be omitted in MVP).

## States
- Loading:
  - Saving; disable inputs and show loading on primary CTA.
- Error:
  - Validation: inline field error(s).
  - Network/unknown: banner with retry.
- Success:
  - Account saved; navigation occurs.

## Copy (key text)
- Create title: “New account”
- Edit title: “Edit account”
- Name label: “Account name”
- Name hint: “e.g., Cash USD”
- Type label: “Type”
- Types: “Bank”, “Wallet”, “Exchange”, “Cash”, “Other”
- Save: “Save”
- Cancel: “Cancel”
- Validation: “Name is required”
- Paywall preface (if used): “Upgrade to create more accounts.”

## Edge cases
- Duplicate account names:
  - Allowed (names are labels); do not block.
- Offline:
  - Saving disabled with explanation “You’re offline. Changes are disabled.”
