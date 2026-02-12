# FTR-005: Subaccounts inside accounts (unlimited, named)

## Summary
Allow users to create and manage **subaccounts (счета)** inside an account. Each subaccount is a user-named holding with an immutable currency/token (asset) from the catalog.

Source references:
- Product: `docs/prd/prd.md` (subaccount concept), `docs/prd/requirements.md` (FR-030..FR-034)
- Tech: `docs/tech/api_assumptions.md`, `docs/contracts/data_contract.md`, `docs/contracts/api_surface.md`

## User story
As a user, I want to model the concrete holdings inside each account (multiple named subaccounts), so that totals and updates match my real setup.

## Scope / Out of scope
Scope:
- Catalog-driven asset search/select (fiat + crypto).
- Create subaccount inside an account:
  - required `name` (user-defined, not derived from currency),
  - required `asset` from catalog,
  - required initial balance snapshot for today.
- Rename subaccount (name only).
- Delete subaccount (cascades its balance history).
- Enforce limits (optional in MVP v2; if used, see FTR-009).

Out of scope:
- Custom assets/tokens.
- Changing a subaccount’s currency (`asset_id`) after creation.

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user taps “Add subaccount” in an account, when the screen opens, then it allows:
  - entering `name` (required),
  - selecting `asset` (required),
  - entering initial `balance` (required; can be `0`),
  - date defaults to today.
- Given the user submits the form, when the backend succeeds, then:
  - the subaccount is created,
  - the initial snapshot is created,
  - the account detail list updates immediately and the account total changes accordingly.
- Given the user tries to save without a name, then the UI shows a validation error and does not submit.
- Given the user renames a subaccount, when they save, then only the name is updated; currency stays unchanged.
- Given the user deletes a subaccount, when they confirm, then:
  - the subaccount disappears from the account,
  - its history is deleted,
  - totals update.

## UX references (which screens it touches; placeholders ok)
- Screen: Account detail (subaccounts list)
- Screen: Create subaccount
- Screen: Subaccount detail
- UI: Delete confirmation
- Screen: Paywall (if limits are enforced)

## States (loading/empty/error/success)
- Loading: catalog fetch; create/rename/delete operations.
- Empty:
  - Account has no subaccounts → show CTA “Add subaccount”.
  - Catalog empty → error.
- Error: network/unauthorized/unknown with retry.
- Success: subaccount list updates; totals recomputed.

## Data needs (entities + fields)
- Read-only catalog `assets`
  - `id: uuid`
  - `kind: "fiat" | "crypto"`
  - `code: text`
  - `name: text`
  - Optional: `decimals: int` (helpful for display/input)
- `subaccounts` (user-owned)
  - `id: uuid`
  - `account_id: uuid`
  - `asset_id: uuid` (immutable)
  - `name: text`
  - `archived: bool`
  - `sort_order: int?`
  - `created_at, updated_at: timestamptz`
- `balance_entries` initial snapshot is created on subaccount creation (see FTR-006).

## Analytics (events, optional)
- `subaccount_created { account_id, asset_kind }`
- `subaccount_deleted { account_id, asset_kind }`

## Open questions (if any)
None for MVP v2.
