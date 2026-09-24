# Run 2026-09-24: First Android Release

- **Scope:** full regression before the first Android production release. Core money tracking
  and payments.
- **Commit under test:** `6a77fc3` (main).
- **Backend:** the hosted Supabase project shared by dev and prod.
- **Runner:** Claude Code, following `docs/qa/regression-runbook.md`.
- **Environment:**
  - macOS; JDK 21 via `flutter config --jdk-dir` (see QA-031);
  - AVD `Medium_Phone` (Android, Gboard);
  - dev debug build for the E cases, prod release build for E17.
- **Cases:** `docs/qa/cases/code.md`, `docs/qa/cases/emulator.md`, `docs/qa/cases/device.md`.
- **Result:** 2 blockers (QA-001, QA-002) and 9 confirmed high or medium bugs. The device layer is
  handed to the owner.
- **Cleanup:** every QA user was hard-deleted. After the run: 0 `qa+%` users, 0 orphan profiles,
  0 soft-deleted users, and plan counts are back to baseline.

**Statuses:**
- `pass`
- `fail` (with a QA id)
- `partial`
- `not run` (with a reason)
- `pending` (owner)

## Release Gates
All of these must be `pass` or explicitly accepted before the production rollout:

1. QA-001: RPC grants closed. Section 1 of `qa/sql/health.sql` returns 0 rows.
2. QA-002: account deletion removes user data. This is a Google Play policy requirement.
3. The code suite `qa/run.sh` is green, except for findings that were accepted.
4. Device P1, P2, P4 (first two rows), L2 and R1 pass.
5. Emulator E1–E8 pass, with no crash.

## Code Layer (`qa/run.sh`)
The suite was run twice with identical results: 29 passed, 6 failed. Every failure maps to a finding.

| # | Scenario | File | Status | Finding |
|---|---|---|---|---|
| C1 | 401 without or with a garbage token; 404 on unknown route | `auth_profile.test.ts` | pass | |
| C2 | `/me` for a new user: free plan and free limits | `auth_profile.test.ts` | pass | QA-030 |
| C3 | Cross-user isolation on every mutating route | `auth_profile.test.ts` | pass | |
| C4 | Base asset rules, free vs pro | `auth_profile.test.ts` | pass | |
| C5 | Assets `is_locked` for free and pro; core rates present | `assets.test.ts` | pass | |
| C6 | Assets list without `kind` | `assets.test.ts` | fail | QA-018 |
| C7 | Accounts CRUD, archive, validation | `accounts.test.ts` | pass | |
| C8 | Accounts: free limit of 5, archived counted, pro unlimited | `accounts.test.ts` | pass | |
| C9 | Accounts: parallel create race | `accounts.test.ts` | pass | QA-017 |
| C10 | Account delete cascades | `accounts.test.ts` | pass | |
| C11 | Subaccounts: CRUD, fiat and crypto decimals | `subaccounts_balance.test.ts` | pass | |
| C12 | Subaccounts: amount and decimals validation, negative allowed | `subaccounts_balance.test.ts` | pass | |
| C13 | Subaccounts: locked asset 403 on free | `subaccounts_balance.test.ts` | pass | |
| C14 | Subaccounts: free limit of 15 across accounts | `subaccounts_balance.test.ts` | pass | |
| C15 | Balance: set, unchanged rejected | `subaccounts_balance.test.ts` | pass | |
| C16 | Balance: `0100` vs `100` | `subaccounts_balance.test.ts` | fail | QA-016 |
| C17 | Totals vs cache with archived subaccounts | `subaccounts_balance.test.ts` | fail | QA-020 |
| C18 | History: cursor pagination, diffs | `history_analytics.test.ts` | pass | QA-019 |
| C19 | Analytics: empty, USD and EUR base, zero excluded, caps | `history_analytics.test.ts` | pass | |
| C20 | Contact developer: validation, default subject, rate limit | `support_delete.test.ts` | pass | |
| C21 | Delete my account removes data | `support_delete.test.ts` | fail | QA-002 |
| C22 | Webhook: secret, process once, dedupe, unknown user → 503 | `billing_security.test.ts` | pass | |
| C23 | Webhook: `TRANSFER` payload | `billing_security.test.ts` | fail | QA-007 |
| C24 | RevenueCat refresh: free stays free, one ledger row | `billing_security.test.ts` | pass | |
| C25 | `rates_sync` rejects a bad secret | `billing_security.test.ts` | pass | |
| C26 | `api_*` RPCs not callable through PostgREST | `billing_security.test.ts` | fail | QA-001 |
| C27 | Prod health: grants, cron, rates freshness, leftovers | `qa/sql/health.sql` | fail (grants only; cron, rates and leftovers OK) | QA-001 |

## Emulator Layer

| # | Scenario | Status | Finding |
|---|---|---|---|
| E1 | First launch: carousel → Sign up (password rules, confirm mismatch) → first paywall shown once → close | pass | QA-033 |
| E2 | Sign out → Sign in (wrong password error) → kill and relaunch restores the session | pass | QA-033 |
| E3 | Overview: empty state, guided tour, pull to refresh | pass | |
| E4 | Account: create, edit, archive, archived list, unarchive, delete | partial: create and validation pass; edit, archive and delete covered by the code layer (C7) | |
| E5 | Subaccount: create fiat and crypto, currency search, `,` and `.` input, negative input, rename, delete, Android back | partial: create fiat and crypto, currency search, `,` and negative input pass; rename, delete and Android back not run on the emulator (API covered by C11) | QA-015 (not reproduced) |
| E6 | Update balance: new value, same value error, history, load more | pass | |
| E7 | Limits: 6th account and 16th subaccount → paywall | fail | QA-023 |
| E8 | Paywall with Test Store: buy from each entry point (single pop), cancel, restore | fail | QA-003, QA-004 |
| E9 | Paywall error or loading state can be closed | not run (state not reproducible on demand) | QA-010 |
| E10 | Base currency free and pro; after buying from this flow | pass (EUR base, conversion correct) | QA-021, QA-033 |
| E11 | Analytics: empty and with data | pass | |
| E12 | Offline: cold start signed in, actions offline, reconnect | fail | QA-009 (not reproduced), QA-013, QA-032 |
| E13 | Session invalidated on the server → 401 → sign in again as the same user | fail | QA-005 |
| E14 | Google OAuth: open, then close the Custom Tab | fail | QA-008 |
| E15 | Language ru/en across key screens; theme light/dark | pass (untranslated errors aside) | QA-032 |
| E16 | Contact developer; delete account | fail | QA-002 |
| E17 | Prod release APK smoke (R8) | pass: sign up, account, subaccount, set balance, analytics, paywall with no billing; no crash | QA-022, QA-034 |
| E18–E28 | Cases added after this run (account edit, archive and delete; subaccount rename, delete and back; history pagination; account-limit purchase; other paywall entry points; restore; manage subscription; legal links; profile refresh) | not run: added after the run | |

## Device Layer (owner)
See `docs/qa/cases/device.md`. The owner has not run these yet.

| # | Scenario | Status | Finding |
|---|---|---|---|
| P1 | First purchase, monthly | pending | |
| P2 | Cancel and decline | pending | |
| P3 | Pending payment | pending | QA-006 |
| P4 | Paywall entry points, single pop | pending | QA-003 |
| L1 | Renewals | pending | |
| L2 | Cancel → expire → free, base reset | pending | QA-026, QA-029 |
| L3 | Resubscribe; monthly ↔ annual | pending | |
| L4 | Billing problem (optional) | pending | |
| R1 | Reinstall → Pro, restore | pending | |
| R2 | Another app user, same Google account (transfer) | pending | QA-007 |
| R3 | Delete account while subscribed | pending | QA-002 |
| D1 | Google sign-in; cancel the Custom Tab; Apple on Android | pending | QA-008, QA-012 |
| D2 | Dev and prod installed together, OAuth callback | pending | QA-011 |
| S | Release-build smoke | pending | |
| X1–X3 | Owner-only extras | pending | QA-015 |
