# SPEC-0007: Hard Delete My Account

- **Type:** bug
- **Status:** Resolved
- **Priority:** P0
- **Owner:** claude
- **Created:** 2026-09-24
- **Resolved:** 2026-09-24

## Goal
Close QA-002: in-app account deletion removes the auth user and all user data, and the copy says so.

## User Or Product Impact
Google Play requires in-app account deletion to delete server data. Users see accurate copy and a
warning that a store subscription is not cancelled automatically.

## Current Behavior
- `handleDeleteMyAccount` in `backend/supabase/functions/api/index.ts` calls
  `auth.admin.deleteUser(userId, true)` (soft delete). The `auth.users` row stays, so the
  `on delete cascade` FKs never fire; profile, accounts, subaccounts and balance entries remain.
- Profile copy says only local data is deleted; the confirm dialog does not mention subscriptions.

## Desired Behavior
- `deleteUser(userId)` hard-deletes; cascade removes all user rows.
- `profileDeleteAccountBody` says server data is permanently deleted.
- `profileDeleteConfirmBody` says the action cannot be undone and an active store subscription must
  be cancelled in the store.

## Scope
- One-argument backend change and deploy of the `api` Edge Function.
- EN/RU copy for `profileDeleteAccountBody` and `profileDeleteConfirmBody`; regenerate l10n.

## Out Of Scope
- Cancelling store subscriptions server-side, RevenueCat customer deletion.
- Cleanup of previously soft-deleted users (none exist on prod as of 2026-09-24).

## Constraints
- EN and RU ARB files stay in sync; generated l10n files are regenerated, not hand-edited.

## Implementation Notes
- EN body: "Your accounts, balances and history will be permanently deleted from our servers, and
  you will be signed out."
- EN confirm: "This action cannot be undone. An active Google Play or App Store subscription is not
  cancelled automatically — cancel it in the store."
- RU mirrors the same meaning.

## Acceptance Criteria
- [x] `delete_my_account` test in `qa/api/support_delete.test.ts` passes on prod (no profile/accounts left).
- [x] No `auth.users` row with `deleted_at` set remains for the deleted user.
- [x] Profile shows the new copy in EN and RU.

## Verification
- `qa/run.sh qa/api/support_delete.test.ts`
- `flutter analyze`, `flutter test` in `client/`

## Documentation Updates
- `docs/qa/findings.md`: mark QA-002 resolved and verified.

## Rollout Notes
Deploy the `api` Edge Function to the hosted project. Copy change ships with the next app build.
