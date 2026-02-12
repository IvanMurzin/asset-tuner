# FTR-004: Accounts CRUD (create/edit/archive/delete)

## Summary
Allow users to create and manage top-level accounts (Bank/Wallet/Exchange/Cash/Other), including archiving (hide from totals) and deletion (server-side cascade).

Source references:
- Product: `docs/prd/prd.md` (Account concept + flows), `docs/prd/requirements.md` (FR-020..FR-023)
- Tech: `docs/tech/api_assumptions.md` (tables + `DELETE /account`), `docs/adr/ADR-0002-edge-functions-api.md` (writes via Edge Functions)

## User story
As a user, I want to model where my money is stored (banks, wallets, cash) so that totals and history are organized like my real world.

## Scope / Out of scope
Scope:
- Create account with `name` and `type` (Bank/Wallet/Exchange/Cash/Other).
- Edit account name/type.
- Archive/unarchive account:
  - archived accounts are hidden from Main totals by default,
  - archived accounts remain recoverable.
- Delete account:
  - requires explicit confirmation,
  - performed via Edge Function to cascade delete dependent rows (account assets + balance entries).

Out of scope:
- Multi-level nesting beyond Account → Subaccounts (explicit non-goal; see `docs/prd/non_goals.md`).
- Account search/filter (nice-to-have only; see `docs/prd/prd.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user is signed in, when they create an account with a name and type, then the account appears in their account list and is included in totals (once it has assets/balances).
- Given the user edits an account’s name or type, when they save, then the updated values persist and are reflected across devices after refresh.
- Given the user archives an account, when they confirm, then:
  - the account is hidden from the default Main list and excluded from the default global total,
  - the account can be shown via an “Archived” section and unarchived.
- Given the user deletes an account, when they confirm deletion, then:
  - the client calls `DELETE /account` Edge Function (see `docs/tech/api_assumptions.md`),
  - on success, the account and its dependent data no longer appear in the app.
- Given the delete request fails, when the app renders the failure, then it shows an error state with retry (except for validation errors which must be corrected).

## UX references (which screens it touches; placeholders ok)
- Screen: Accounts list
- Screen: Create/Edit account
- UI: Archive action (swipe/overflow)
- UI: Delete confirmation dialog
- Screen/section: Archived accounts (optional placement: Accounts list bottom)

## States (loading/empty/error/success)
- Loading: accounts list fetch; create/edit/archive/delete operations.
- Empty: no active accounts → show CTA “Create your first account”.
- Error: network/unauthorized/unknown with retry.
- Success: list updates; optimistic update allowed if reconciled on refresh.

## Data needs (entities + fields)
- `accounts` (user-owned)
  - `id: uuid`
  - `user_id: uuid`
  - `name: text`
- `type: enum/text` in {bank, wallet, exchange, cash, other}
  - `archived: boolean`
  - `created_at, updated_at: timestamptz`
- Edge Function:
  - `DELETE /account { account_id }` (response contract per `docs/tech/api_assumptions.md`)

## Analytics (events, optional)
- `account_created { type }`
- `account_archived { account_id }`
- `account_deleted { account_id }`

## Open questions (if any)
- Should archived accounts be excluded from totals always, or should Main have a toggle “Include archived in totals”?
