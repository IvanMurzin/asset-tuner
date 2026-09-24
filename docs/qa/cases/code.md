# Code Cases

Automated by `qa/run.sh` (Deno API suite in `qa/api/`) and `qa/sql/health.sql` (read-only
production checks). Tests assert the **intended** behavior. A failure is either a regression or
a known finding; the failure message points to the relevant `QA-NNN`.

| # | Scenario | File | Related finding |
|---|---|---|---|
| C1 | 401 with a missing or garbage token; 404 on an unknown route | `qa/api/auth_profile.test.ts` | |
| C2 | `/me` for a new user: free plan, free limits, null base asset | `qa/api/auth_profile.test.ts` | QA-030 |
| C3 | Cross-user isolation on every read and mutating route | `qa/api/auth_profile.test.ts` | |
| C4 | Base asset rules: free vs pro, unknown and invalid ids | `qa/api/auth_profile.test.ts` | |
| C5 | Assets `is_locked` for free and pro; core currencies have positive rates | `qa/api/assets.test.ts` | |
| C6 | `/assets/list` without `kind` returns both kinds | `qa/api/assets.test.ts` | QA-018 |
| C7 | Accounts: CRUD, archive, unarchive, validation | `qa/api/accounts.test.ts` | |
| C8 | Accounts: free limit of 5 counts archived accounts; pro is unlimited | `qa/api/accounts.test.ts` | |
| C9 | Accounts: parallel creates do not exceed the free limit | `qa/api/accounts.test.ts` | QA-017 |
| C10 | Account delete cascades to subaccounts and balance entries | `qa/api/accounts.test.ts` | |
| C11 | Subaccounts: CRUD, fiat and crypto decimals, initial balance entry | `qa/api/subaccounts_balance.test.ts` | |
| C12 | Subaccounts: amount and decimals validation; negative amounts allowed | `qa/api/subaccounts_balance.test.ts` | |
| C13 | Subaccounts: locked asset is 403 on free and allowed on pro | `qa/api/subaccounts_balance.test.ts` | |
| C14 | Subaccounts: free limit of 15 across all accounts, archived included | `qa/api/subaccounts_balance.test.ts` | |
| C15 | Balance: set, unchanged value rejected, current amount follows | `qa/api/subaccounts_balance.test.ts` | |
| C16 | Balance: `0100` vs `100` counts as unchanged | `qa/api/subaccounts_balance.test.ts` | QA-016 |
| C17 | Account totals vs cache with archived subaccounts | `qa/api/subaccounts_balance.test.ts` | QA-020 |
| C18 | History: cursor pagination has no duplicates or gaps; `diff_amount` is correct | `qa/api/history_analytics.test.ts` | QA-019 |
| C19 | Analytics: empty user, USD and EUR base, zero excluded, caps | `qa/api/history_analytics.test.ts` | |
| C20 | Contact developer: validation, default subject, 5 per hour | `qa/api/support_delete.test.ts` | |
| C21 | `delete_my_account` removes the user and all data | `qa/api/support_delete.test.ts` | QA-002 |
| C22 | Webhook: secret check, process once, dedupe replays, unknown user gives 503 | `qa/api/billing_security.test.ts` | |
| C23 | Webhook: `TRANSFER` payload without `app_user_id` | `qa/api/billing_security.test.ts` | QA-007 |
| C24 | RevenueCat refresh: free stays free, one ledger row per user | `qa/api/billing_security.test.ts` | |
| C25 | `rates_sync` rejects a missing or wrong secret | `qa/api/billing_security.test.ts` | |
| C26 | `api_*` RPCs are not callable through PostgREST with the publishable key | `qa/api/billing_security.test.ts` | QA-001 |
| C27 | Prod health: grants, cron, rates freshness, pro users, soft-deleted users, leftovers | `qa/sql/health.sql` | QA-001 |

## Adding A Case
- Add it to the matching `qa/api/*.test.ts` file with `withUsers(...)` so cleanup is automatic.
- Add a row here with the next `C` id.
- Keep it finite: 1–3 assertions per behavior.
