# User journeys (MVP v2 rewrite)

These journeys describe the key end-to-end flows that the MVP UI must support, based on:
- `docs/prd/*` (product truth)
- `docs/features/*` (testable acceptance criteria)
- `docs/tech/*` (error + offline assumptions)

Screen IDs referenced below are defined in `docs/ux/screen_map.md`.

## UJ-001: First launch → sign in → reach Main
1. User opens the app → sees `SCR-001` (session restore).
2. If no valid session → user lands on `SCR-002` (Sign-in).
3. User enters email and requests OTP → `SCR-002` shows “check your email” success state.
4. User completes OTP verification (via email link / code, depending on implementation) → app establishes a session.
5. App bootstraps profile (upsert) and ensures `base_currency` exists.
6. If onboarding requires base currency confirmation → navigate to `SCR-003` (Onboarding base currency).
7. Otherwise → navigate to `SCR-004` (Main).

Navigation after auth:
- Bottom tabs: `Main (SCR-004)`, `Analytics (SCR-017)`, `Profile (SCR-009)`.

## UJ-002: Create first account (happy path)
Precondition: user is authenticated and on paid/free tier (no limits exceeded).
1. From `SCR-004` (Main) empty state, user taps “Create account” → `SCR-006` (Account form, create).
2. User enters account name and selects type → taps “Save”.
3. On success → navigate to `SCR-007` (Account detail) or back to `SCR-004` (Main) depending on routing choice.
4. User sees the new account in lists and (once it has subaccounts/balances) it contributes to totals.

## UJ-003: Add a subaccount (счёт) to an account
1. From `SCR-007` (Account detail), user taps “Add subaccount” → `SCR-008` (Create subaccount).
2. Screen fetches catalog; user selects an asset (currency/token).
3. User enters:
   - subaccount name (required),
   - initial balance (required),
   - date defaults to today.
4. User confirms:
   - Subaccount is created and initial snapshot is stored.
   - User returns to `SCR-007` with updated subaccounts list and updated account total.

## UJ-004: Update a balance (snapshot-only)
1. From `SCR-010` (Subaccount detail) or `SCR-007` (Account detail), user taps “Update balance” → `SCR-011` (Update balance).
2. User enters snapshot amount (required). Date is today.
3. User submits:
   - Server stores snapshot and computes diff vs previous snapshot.
4. User returns to `SCR-010` to see updated history; `SCR-004` totals update after refresh.

## UJ-005: Drill down from Main
1. From `SCR-004` (Main), user taps an account card → `SCR-007` (Account detail).
2. From `SCR-007`, user taps a subaccount → `SCR-010` (Subaccount detail).
3. From `SCR-010`, user paginates history (when > 50 entries) and/or adds a new entry via `SCR-011`.

## UJ-006: Change base currency (free vs paid)
1. User opens `SCR-012` (Base currency settings) from `SCR-009` (Settings).
2. Screen fetches fiat catalog and shows current selection.
3. If user selects USD/EUR/RUB on free tier → save succeeds.
4. If user selects any other fiat on free tier → app shows `SCR-013` paywall (reason “base currency”) and does not persist the change.
5. If user has entitlement for “any base currency” → save succeeds; `SCR-004` totals recompute in the new base currency.

## UJ-007: Hit a limit → upgrade
1. User attempts a gated action on free tier:
   - create 6th account (from `SCR-006`), or
   - add 21st subaccount (from `SCR-008`), or
   - select non-free base currency (from `SCR-012`).
2. App blocks the action and shows `SCR-013` (Paywall) with reason-specific messaging.
3. User starts purchase → sees loading state, then success or error.
4. On success, app refreshes entitlements and returns user to the original action context to retry successfully.

## UJ-008: Archive/unarchive and delete accounts
1. From `SCR-004` (Main) or `SCR-007` (Account detail), user opens account actions.
2. Archive:
   - Confirm → account moves into “Archived” section and is excluded from default totals on `SCR-004`.
   - Unarchive → account returns to active list.
3. Delete:
   - Confirm destructive action → client calls delete operation.
   - On success → account and dependent data disappear from the app.

## UJ-009: Offline read-only behavior
1. User is offline and opens `SCR-004` (Main).
2. If cached snapshot exists → show snapshot + “Offline / Last updated”.
3. If no snapshot → show offline empty/error state with “Try again” (disabled until online).
4. While offline, mutation CTAs (create account, add asset, add balance, save base currency) are disabled and show a brief explanation.
