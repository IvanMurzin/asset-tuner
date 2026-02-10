# FTR-005: Supported assets inside accounts

## Summary
Allow adding/removing supported assets (fiat + crypto) into accounts using a backend-provided catalog; track “asset positions” (account-asset pairs) for limits enforcement.

Source references:
- Product: `docs/prd/prd.md` (Asset concept; known assets only), `docs/prd/requirements.md` (FR-030..FR-034)
- Tech: `docs/tech/api_assumptions.md` (`assets`, `account_assets`), `docs/prd/glossary.md` (asset position)

## User story
As a user, I want to add the currencies/tokens I hold in each account/wallet so that totals are accurate and organized.

## Scope / Out of scope
Scope:
- Catalog-driven asset search/select:
  - fiat (ISO currencies)
  - crypto (tokens/coins)
- Add asset to an account (creates an `account_assets` row).
- Remove asset from an account (deletes the `account_assets` row and associated balance history, or disallows removal unless history is deleted — see open question).
- Enforce free-tier limits on total asset positions (see FTR-009).

Out of scope:
- Custom assets/tokens (explicitly not in MVP; see `docs/prd/non_goals.md`).
- Multiple nested sub-accounts (no deeper than Account → Assets).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user opens “Add asset” for an account, when the screen loads, then it fetches the asset catalog from Supabase and allows searching by code/symbol/name.
- Given the user selects a supported asset, when they confirm, then an asset position (account-asset pair) is created and shown in the account detail.
- Given the account already contains the selected asset, when the user tries to add it again, then the app prevents duplicates and shows a validation error.
- Given the user is on the free tier and would exceed the “asset positions” limit by adding an asset, when they attempt to confirm, then the app shows the paywall (FTR-009) and does not create the asset position.
- Given the user removes an asset from an account, when they confirm removal, then the asset position is removed and it no longer appears in totals.

## UX references (which screens it touches; placeholders ok)
- Screen: Account detail (assets list)
- Screen: Add asset (search/select)
- UI: Remove asset confirmation
- Screen: Paywall (FTR-009)

## States (loading/empty/error/success)
- Loading: catalog fetch; add/remove operations.
- Empty:
  - Account has no assets → show CTA “Add an asset”.
  - Catalog returns empty → show error (catalog expected to exist).
- Error: network/unauthorized/unknown with retry.
- Success: asset list updates; position count updates.

## Data needs (entities + fields)
- Read-only catalog `assets`
  - `id: uuid`
  - `kind: "fiat" | "crypto"`
  - `code/symbol: text`
  - `name: text`
  - Optional: `decimals: int` (helpful for display/input)
- `account_assets` (user-owned)
  - `id: uuid`
  - `account_id: uuid`
  - `asset_id: uuid`
  - `sort_order: int` (optional; reorder is optional per PRD)
  - `created_at: timestamptz`

## Analytics (events, optional)
- `asset_added_to_account { account_id, asset_kind }`
- `asset_removed_from_account { account_id, asset_kind }`
- `asset_add_blocked_by_limit { limit_type="positions" }`

## Open questions (if any)
- Removal semantics: if an asset has `balance_entries`, do we (a) cascade delete its history on removal, (b) block removal until history is deleted, or (c) auto-archive the position? (`docs/tech/api_assumptions.md` suggests server-side cascades for account deletion, but not for position removal.)

