# QA Findings

First found in run `docs/qa/runs/2026-09-24-android-release.md`, the pre-release regression for the first Android release. The format is
described in `docs/qa/README.md`. Items are ordered by severity. Statuses are updated as the
regression runs.

## Summary
| ID | Severity | Type | Area | Title | Status |
|---|---|---|---|---|---|
| QA-001 | blocker | security | backend | Four `api_*` SECURITY DEFINER RPCs are executable by `anon`/`authenticated` | confirmed-runtime |
| QA-002 | blocker | bug | backend | `delete_my_account` soft-deletes the auth user, so user data is never removed | confirmed-runtime |
| QA-003 | high | bug | billing/client | Paywall can pop twice after a successful purchase or restore | confirmed-runtime |
| QA-004 | high | bug | billing | Sandbox purchases grant Pro in the shared production database | confirmed-runtime |
| QA-005 | high | bug | client/auth | Re-login after a forced 401 sign-out can hang on the sign-in screen | confirmed-runtime |
| QA-006 | medium | bug | billing/client | Google Play pending purchases are shown as an error | confirmed-code |
| QA-007 | medium | bug | billing | `TRANSFER` webhook events are rejected with 400 | confirmed-runtime |
| QA-008 | medium | ux | client/auth | Cancelling Google OAuth leaves the sign-in screen loading for 90 seconds | confirmed-runtime |
| QA-009 | medium | bug | client | Cold start while offline may crash on `SupabaseErrorTranslator` late init | not-reproduced |
| QA-010 | medium | ux | client/paywall | Paywall error and loading states have no close button | confirmed-code |
| QA-011 | medium | bug | client/auth | Dev and prod flavors share the `assettuner://` OAuth callback scheme | confirmed-code |
| QA-012 | medium | ux | client/auth | Apple sign-in button is shown on Android | confirmed-code |
| QA-013 | medium | bug | client | Offline and network errors are not recognized; no HTTP timeouts | confirmed-runtime |
| QA-014 | medium | improvement | client/auth | No "forgot password" flow | confirmed-code |
| QA-015 | low | bug | client | Negative amounts cannot be typed on most Android keyboards | not-reproduced |
| QA-016 | low | bug | backend | Unchanged-balance check compares text (`0100` vs `100`) | confirmed-runtime |
| QA-017 | low | bug | backend | Plan limits can be exceeded with parallel requests | not-reproduced |
| QA-018 | low | bug | backend | `/assets/list` without `kind` returns only crypto | confirmed-runtime |
| QA-019 | low | bug | backend | History cursor loses microseconds and ignores ties | confirmed-code |
| QA-020 | low | bug | backend | Account cached total includes archived subaccounts; live total does not | confirmed-runtime |
| QA-021 | low | bug | client/paywall | Requested base currency is not applied after buying from the base-currency flow (BL-0001) | confirmed-code |
| QA-022 | medium | bug | client/paywall | Paywall opened from Profile says "Unlock any base currency" (args default to `baseCurrency`) | confirmed-runtime |
| QA-023 | low | ux | client | Hitting a limit shows the paywall and an error snackbar at the same time | confirmed-runtime |
| QA-024 | low | bug | backend | Analytics divides by zero when the base asset rate is `0` | confirmed-code |
| QA-025 | low | security | backend | Unmapped DB errors return raw Postgres message, details, and hint | confirmed-code |
| QA-026 | low | improvement | billing | 5-minute subscription sync cooldown delays renewal and expiry in the UI | confirmed-code |
| QA-027 | low | improvement | client | Currency picker is capped at 100 assets per kind, with no pagination | confirmed-code |
| QA-028 | low | docs | docs | UX and architecture docs disagree with the current app | confirmed-code |
| QA-029 | info | improvement | backend | Free-plan downgrade keeps accounts and subaccounts above free limits | confirmed-code |
| QA-030 | info | improvement | backend | New profile has a null base asset; the client fills in USD | confirmed-runtime |
| QA-032 | medium | bug | client/l10n | 29 hardcoded English error messages are shown in the Russian UI | confirmed-runtime |
| QA-033 | low | ux | client | Small UX and accessibility polish from the emulator pass | confirmed-runtime |
| QA-034 | low | ux | client/paywall | Paywall gives no explanation when the store is unavailable | confirmed-runtime |
| QA-031 | low | improvement | tooling | Android toolchain cannot build on Java 25 (Gradle 8.14.3) | confirmed-runtime |

---

## QA-001: Four `api_*` SECURITY DEFINER RPCs are executable by `anon`/`authenticated`
- **Severity:** blocker
- **Type:** security
- **Status:** confirmed-runtime (2026-09-24). Section 1 of `qa/sql/health.sql` on prod lists all four functions with `anon = t` and `authenticated = t`. `qa/api/billing_security.test.ts` called `POST /rest/v1/rpc/api_create_account` with **only the publishable key** and got **200**: an account was created for the QA user's id.
- **Area:** `backend/supabase/migrations`
- **Repro:**
  1. Run section 1 of `qa/sql/health.sql`.
  2. Or call
     `POST {SUPABASE_URL}/rest/v1/rpc/api_create_account` with only the publishable key and a body
     `{"p_user_id":"<any uuid>","p_name":"x","p_type":"bank"}`.
- **Expected:** `anon` and `authenticated` cannot execute any `api_*` function. Only
  `service_role` can, through the Edge Functions.
- **Actual:**
  - Migrations `20260221120000`–`20260221120003` do `drop function` followed by `create function` for
    `api_create_subaccount`, `api_update_subaccount`, `api_update_account` and `api_create_account`.
  - The earlier `revoke`/`grant` migrations (`20260217200132`–`200157`) are not repeated.
  - A re-created function gets the default privileges again, and in Supabase that includes
    `anon`/`authenticated`.
  - These functions are SECURITY DEFINER and trust `p_user_id`. Anyone holding the publishable key,
    which ships inside the APK, can create or edit accounts and subaccounts for any user id.
- **Evidence:** `20260221120000_api_create_subaccount_return_asset_and_usd_rate.sql:1-13` has no
  revoke. Same for `120001`, `120002` and `120003`.
- **Suggested fix:**
  - Add a new migration that runs, for these four function signatures:
    `revoke all on function ... from public, anon, authenticated; grant execute ... to service_role;`.
  - Add the same revoke/grant as a mandatory footer to every future migration that drops and
    re-creates a function.
  - Keep the health-check query as a pre-release gate.
  - Section 1 also lists `handle_auth_user_created` and `handle_balance_entry_insert` as executable. They are trigger functions (`returns trigger`), so PostgREST cannot call them directly. Revoke them in the same migration anyway.

## QA-002: `delete_my_account` soft-deletes the auth user, so user data is never removed
- **Severity:** blocker. Google Play requires in-app account deletion to delete the data.
- **Type:** bug
- **Status:** confirmed-runtime (2026-09-24, prod). After `POST /delete_my_account` returned 200:
  - the auth user is kept, with `deleted_at` set and the email scrambled;
  - the old token gets 401;
  - `profiles` = 1 row and `accounts` = 1 row still exist for that user id.
  - Deleting a user from the Supabase Dashboard is a **hard** delete and does cascade. That is probably why manual checks looked fine.
  - Reproduced through the app UI on the emulator: Profile → Delete account → confirm. Afterwards the database still had the profile (`plan = pro`), 1 account, 16 subaccounts and 17 balance entries.
  - The copy under the button says "Local data will be deleted and you will be signed out", which contradicts the Play policy expectation that server data is deleted.
  - The confirm dialog does not mention that an active store subscription keeps billing.
  - An admin hard delete (`should_soft_delete: false`) of the same user removed everything via cascade, so the fix is a one-argument change plus a copy update.
- **Area:** `backend/supabase/functions/api/index.ts:192`
- **Repro:** Profile → Delete account → confirm. Then query `profiles` and `accounts` for that
  user id.
- **Expected:** the auth user and all of their data (profile, accounts, subaccounts, balance
  entries) are removed. The README smoke test says deletion "cascades user data". Google Play's
  account-deletion policy also requires the data to actually be deleted.
- **Actual:**
  - `auth.admin.deleteUser(userId, true)` passes `shouldSoftDelete = true`.
  - The `auth.users` row stays, so the `on delete cascade` foreign keys never fire.
  - All financial data stays in the database.
- **Suggested fix:**
  - Call `deleteUser(userId)` (hard delete), or explicitly delete the user's rows before a soft
    delete.
  - Clean up users who were already soft-deleted, using section 9 of `health.sql`.
  - Decide what to show a user who deletes the account while subscribed (see QA-004 and device case R3 in `docs/qa/cases/device.md`).

## QA-003: Paywall can pop twice after a successful purchase or restore
- **Severity:** high
- **Type:** bug
- **Status:** confirmed-runtime (emulator, Test Store).
  1. Account → Add subaccount at the 15/15 limit → the paywall opens.
  2. "Test valid purchase".
  3. The app lands on the **account detail** screen, not the Add subaccount form. The form was popped together with the paywall.
- **Area:** `client/lib/presentation/paywall/page/paywall_page.dart:308-311`, `:361-362`, `:444-449`
- **History:** commit `d60d052` ("fix double pop on purchase") only covered the auto-dismiss during an in-flight purchase. The `finally` `setState` still triggers the second pop, so the fix is incomplete.
- **Repro:**
  1. Open Account → Add subaccount → tap a locked currency. The paywall opens.
  2. Buy.
- **Expected:** the paywall closes once and the user is back on the Add subaccount screen.
- **Actual (suspected):**
  - `_onPurchaseOrRestoreCompleted` calls `context.pop`.
  - Then `finally` runs `setState(() => _isProcessingAction = false)` while the route is still
    mounted during its exit animation.
  - That rebuild sees `isPro && !_isProcessingAction` and schedules a second `context.pop`, which
    pops the screen under the paywall.
  - Restore goes through the same path.
- **Suggested fix:**
  - Set a `_didComplete` flag before popping, and skip both the `setState` in `finally` and the
    auto-dismiss when it is set.
  - Add a widget test for purchase → single pop.

## QA-004: Sandbox purchases grant Pro in the shared production database
- **Severity:** high
- **Type:** bug
- **Status:** confirmed-runtime. A Test Store purchase on the dev flavor produced a ledger row `INITIAL_PURCHASE`, `environment = SANDBOX`, `store = TEST_STORE`, and set `profiles.plan = pro` in the shared prod database.
- **Area:** `backend/supabase/functions/revenuecat_webhook/index.ts`, `_shared/revenuecat_entitlements.ts`, `docs/flavors-and-accounts.md`
- **Repro:** a license tester buys Pro from the internal track. The tester's profile becomes `pro`
  in the production database.
- **Expected:** internal testing does not disturb production state, or it is at least explicit
  and reversible.
- **Actual:**
  - Dev and prod share one Supabase and one RevenueCat project.
  - The webhook and refresh ignore `event.environment` (`SANDBOX` vs `PRODUCTION`).
  - Test Store purchases on the dev flavor also resolve to Pro.
- **Suggested fix:** this is acceptable for launch only if testers are known accounts. Longer
  term, either:
  - store `environment` in the ledger and refuse to grant Pro from sandbox in prod; or
  - split dev and prod projects.

  Document the decision in `docs/flavors-and-accounts.md` either way.

## QA-005: Re-login after a forced 401 sign-out can hang on the sign-in screen
- **Severity:** high
- **Type:** bug
- **Status:** confirmed-runtime (emulator).
  1. Revoke all sessions (`POST /auth/v1/logout?scope=global`).
  2. Pull to refresh. The app goes to Sign in, which is correct.
  3. Sign in with the same user. The logs show `signInWithPassword success` and `authCompleted`, but the app **stays on Sign in**. It was still there 30 seconds later.
  4. Only killing and relaunching the app lands the user on Main.
- **Area:** `client/lib/presentation/auth/bloc/auth_cubit.dart:167`, `client/lib/data/auth/repository/auth_repository.dart:30-39`
- **Repro:**
  1. Sign in.
  2. Invalidate the session on the server (for example, sign out all sessions for the user), or
     wait until the refresh token is revoked.
  3. Trigger any API call. The app sends the user to Sign in.
  4. Sign in with the same user.
- **Expected:** the user lands on Overview.
- **Actual (suspected):**
  - `forceLocalSignOut` only changes cubit state. It does not clear the Supabase session.
  - `watchSession()` uses `.distinct()`, so a new session for the same user id compares equal and
    is filtered out. The user stays on Sign in.
  - On relaunch, the stale persisted session can loop back into 401s.
- **Suggested fix:**
  - Have `forceLocalSignOut` call `supabase.auth.signOut(scope: local)` so the stream emits
    `null`.
  - Or compare sessions by access token, not by user id.

## QA-006: Google Play pending purchases are shown as an error
- **Severity:** medium
- **Type:** bug
- **Status:** confirmed-code. The device check is case P3 in `docs/qa/cases/device.md`.
- **Area:** `client/lib/presentation/paywall/page/paywall_page.dart:274-292`
- **Repro:** a license tester buys with the test card "Slow test card, approves after a few
  minutes".
- **Expected:** a neutral "Payment pending, Pro will activate when the payment completes"
  message. Pro activates later through the webhook and the listener.
- **Actual:** `PurchasesErrorCode.paymentPendingError` goes down the generic branch, so the user
  sees an error snackbar with the raw SDK message.
- **Suggested fix:** handle `paymentPendingError` explicitly with a localized info message and
  close the paywall.

## QA-007: `TRANSFER` webhook events are rejected with 400
- **Severity:** medium
- **Type:** bug
- **Status:** confirmed-runtime. A synthetic `TRANSFER` payload without `app_user_id` returns `400 event.app_user_id is required`. The end-to-end effect is to be confirmed on a device, case R2 in `docs/qa/cases/device.md`.
- **Area:** `backend/supabase/functions/revenuecat_webhook/index.ts:100-103`
- **Repro:** restore purchases while signed in as app user B on a Google account whose
  subscription belongs to app user A.
- **Expected:** B becomes Pro and A is downgraded.
- **Actual (suspected):**
  - `TRANSFER` payloads carry `transferred_from`/`transferred_to` and no `app_user_id`, so the
    webhook returns 400.
  - A stays `pro` in the database until A's next refresh. B is fixed only by the client-side
    refresh.
- **Suggested fix:** for `TRANSFER`, refresh every id in `transferred_from` and `transferred_to`
  via the REST lookup.

## QA-008: Cancelling Google OAuth leaves the sign-in screen loading for 90 seconds
- **Severity:** medium
- **Type:** ux
- **Status:** confirmed-runtime (emulator).
  - Google sign-in opens in **full Chrome**, not a Custom Tab, so Android back navigates Chrome history and does not return to the app.
  - Each attempt leaves another Chrome tab open.
  - After switching back to the app, every button is disabled and the Sign in button shows a spinner. Tapping Google again does nothing.
- **Area:** `client/lib/data/auth/repository/auth_repository.dart:22`, `:84-110`
- **Repro:** Sign in → Google → close the Custom Tab or press back.
- **Expected:** the sign-in buttons are usable again immediately.
- **Actual:** the completer only finishes on `signedIn` or after the 90-second timeout. All
  buttons stay disabled until then.
- **Suggested fix:** on `AppLifecycleState.resumed`, if no session arrived within about 1–2
  seconds, cancel the pending OAuth attempt.

## QA-009: Cold start while offline may crash on `SupabaseErrorTranslator` late init
- **Severity:** medium
- **Type:** bug
- **Status:** not-reproduced. An offline cold start while signed in shows an inline error with Retry and no crash. The `static late` field is still fragile; keep it low.
- **Area:** `client/lib/core/supabase/supabase_error_translator.dart:30`
- **Repro:** sign in, kill the app, turn on airplane mode, launch.
- **Expected:** an error state with Retry.
- **Actual (suspected):**
  - `static late Map _translations` is set only by `LocaleCubit.load()`.
  - A failure mapped before that throws `LateInitializationError`.
- **Suggested fix:** initialize `_translations` with `_fallbackTranslations`.

## QA-010: Paywall error and loading states have no close button
- **Severity:** medium
- **Type:** ux
- **Status:** confirmed-code
- **Area:** `client/lib/presentation/paywall/page/paywall_page.dart:402-430`
- **Repro:** open the paywall while RevenueCat identity or the profile failed to load. This
  includes the automatic first-auth paywall.
- **Expected:** a visible close button.
- **Actual:** a bare `Scaffold` with an inline error. Only Android back gets the user out.
- **Suggested fix:** use the same app bar with a close action in every paywall state.

## QA-011: Dev and prod flavors share the `assettuner://` OAuth callback scheme
- **Severity:** medium
- **Type:** bug
- **Status:** confirmed-code. The device check is case D2 in `docs/qa/cases/device.md`.
- **Area:** `client/android/app/build.gradle.kts:109`, `:120`
- **Repro:** install both dev and prod, then sign in with Google in either one.
- **Expected:** the callback returns to the app that started the sign-in.
- **Actual:** both apps register `assettuner://login-callback`. Android shows a chooser or opens
  the wrong app.
- **Suggested fix:**
  - Use `assettuner-dev` for dev, with a matching `OAUTH_REDIRECT_URI` in `.config.dev.json`.
  - Add that redirect URL to Supabase Auth.

## QA-012: Apple sign-in button is shown on Android
- **Severity:** medium
- **Type:** ux
- **Status:** confirmed-code. Whether the web flow works is to-verify on a device.
- **Area:** `client/lib/data/auth/repository/auth_repository.dart:220`
- **Expected:** Apple is shown on Android only when the Supabase Apple web OAuth is configured and
  tested.
- **Actual:** the provider list is hardcoded as `[email, google, apple]` on every platform.
- **Suggested fix:** hide Apple on Android unless it is explicitly enabled by config.

## QA-013: Offline and network errors are not recognized; no HTTP timeouts
- **Severity:** medium
- **Type:** bug
- **Status:** confirmed-runtime (emulator, airplane mode).
  - An offline cold start shows "Что-то пошло не так." plus the **English** "Unable to load profile". Creating an account offline shows the English snackbar "Unable to create account".
  - The UI never says "No connection".
  - After reconnecting, the screen does not reload by itself; each error block needs its own Retry (profile, then accounts).
- **Area:** `client/lib/core/supabase/supabase_failure_mapper.dart:12`
- **Expected:** a clear "No connection" message, and requests that time out.
- **Actual:**
  - Only `SocketException` maps to the network failure. `ClientException` and
    `AuthRetryableFetchException` end up as `unknown` or show the raw message.
  - Apart from the 30-second subscription sync, requests have no timeout, so spinners can hang on
    a bad network.
- **Suggested fix:**
  - Map `ClientException`, `AuthRetryableFetchException`, `TimeoutException` and
    `HandshakeException` to `network`.
  - Add about a 20-second timeout to function calls.

## QA-014: No "forgot password" flow
- **Severity:** medium
- **Type:** improvement
- **Status:** confirmed-code
- **Area:** `client/lib/presentation/auth`
- **Expected:** a user who forgot the password can recover the account.
- **Actual:** there is no reset flow, so the account is effectively lost.
- **Suggested fix:**
  - Add Supabase `resetPasswordForEmail`, with a deep link back into the app and a
    set-new-password screen.
  - At minimum, add a "Forgot password?" link to the support contact.

## QA-015: Negative amounts cannot be typed on most Android keyboards
- **Severity:** low
- **Type:** bug
- **Status:** not-reproduced on Gboard. The numeric layout shows `-`, and `-1234,56` was typed and saved. It may still differ on the Samsung keyboard; check on a device (case X1 in `docs/qa/cases/device.md`).
- **Area:** `client/lib/core_ui/components/ds_decimal_field.dart:38`
- **Expected:** negative balances (debts, credit cards) can be entered. The backend accepts them.
- **Actual:** `numberWithOptions(decimal: true)` without `signed: true` hides `-` on Gboard.
- **Suggested fix:** add `signed: true`, if negatives are part of the product.

## QA-016: Unchanged-balance check compares text
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-runtime. `0100` after `100` returns 200 and creates a new entry.
- **Area:** `backend/supabase/migrations/20260417173000_api_set_subaccount_balance_reject_unchanged.sql:43-54`
- **Actual:** `0100` vs `100` and `-0` vs `0` count as changes and create duplicate history
  entries.
- **Suggested fix:** compare `atomic_to_numeric(...)` values, and/or normalize the amount on
  insert.

## QA-017: Plan limits can be exceeded with parallel requests
- **Severity:** low
- **Type:** bug
- **Status:** not-reproduced. Four parallel creates at 4/5 accounts stayed within the limit. This is still possible in theory; keep it low.
- **Area:** `20260221120003:36-39`, `20260221120000:52-55`, `20260217213006:38-47`
- **Actual:** the count and the insert are not serialized, so concurrent creates can exceed 5
  accounts, 15 subaccounts or 5 messages per hour.
- **Suggested fix:** take `pg_advisory_xact_lock(hashtext(p_user_id::text))`, or lock the
  profile row with `select ... for update`, before counting.

## QA-018: `/assets/list` without `kind` returns only crypto
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-runtime. Without `kind`, the response contains only `crypto`.
- **Area:** `api_list_assets`
- **Actual:** the list is ordered by kind ascending with limit 100, so "crypto" sorts first and
  fills the whole page. The client always passes `kind`, so users are not affected today.
- **Suggested fix:** make `kind` required, or apply the limit per kind.

## QA-019: History cursor loses microseconds and ignores ties
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-code
- **Area:** `backend/supabase/functions/api/index.ts:400-404`, `20260218131000:46`
- **Actual:**
  - The cursor passes through JS `Date`, which keeps milliseconds only.
  - Filtering is `created_at < cursor` without an `id` tie-break.
  - Entries created within the same millisecond as the page boundary can be skipped.
- **Suggested fix:** return an opaque cursor made of `created_at` (full precision) plus `id`,
  and filter with `(created_at, id) < (cursor_ts, cursor_id)`.

## QA-020: Account cached total includes archived subaccounts; live total does not
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-runtime. One active subaccount of 50 USD and one archived subaccount of 100 USD give live total = 50 and `cached_total_usd` = 150.
- **Area:** `20260217200023` (recompute) vs `20260217213012` (list accounts);
  `20260421183000` (analytics includes archived subaccounts)
- **Expected:** one consistent rule for archived subaccounts across totals, cache and analytics.
- **Suggested fix:** exclude archived subaccounts everywhere, or include them everywhere, and
  document the rule in `docs/product/capabilities.md`.

## QA-021: Requested base currency is not applied after purchase from the base-currency flow
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-code. It is already `BL-0001` in `docs/backlog.md`.
- **Area:** `client/lib/presentation/settings/page/base_currency_settings_page.dart:189`,
  `client/lib/presentation/paywall/bloc/paywall_args.dart:7`
- **Actual:** `requestedBaseCurrencyCode` is passed to the paywall and never read. After buying,
  the user has to pick the currency and press Save again.
- **Suggested fix:** after a successful purchase, apply the requested base currency, or return it
  as the pop result and let the settings page apply it.

## QA-022: Paywall opens without args are logged as `baseCurrency`
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-code
- **Area:** `client/lib/core/routing/app_router.dart:352-354`;
  callers `profile_page.dart:147` and `add_subaccount_page.dart:202`
- **Actual:**
  - Analytics mislabels the profile Upgrade and locked-currency paywall opens.
  - This is **visible to users**: Profile → Upgrade plan opens the paywall with the subtitle "Unlock any base currency." (confirmed on the prod release build).
- **Suggested fix:** pass explicit `PaywallArgs` everywhere, and add `PaywallReason.profile` and
  `PaywallReason.lockedAsset`.

## QA-023: Hitting a limit shows the paywall and an error snackbar at the same time
- **Severity:** low
- **Type:** ux
- **Status:** confirmed-runtime. At 15/15 subaccounts the paywall opened and, underneath it, a snackbar "Free plan position limit reached" (English copy, wording "position"). After buying, the form was lost because of QA-003.
- **Area:** `account_create_page.dart:57-67`, `add_subaccount_page.dart:89-99`
- **Expected:** the paywall alone. After a purchase, the original action retries or the form stays
  filled.
- **Suggested fix:** suppress the snackbar for `limit_*` codes. Optionally, retry the create after
  a successful purchase.

## QA-024: Analytics divides by zero when the base asset rate is `0`
- **Severity:** low
- **Type:** bug
- **Status:** confirmed-code. It only happens if a zero rate reaches the database; rates_sync
  skips rates of 0 or below.
- **Area:** `backend/supabase/migrations/20260421183000_api_analytics_summary.sql:55-62`, `:118`, `:193`
- **Suggested fix:** treat a base price of 0 or below like null, as `api_list_accounts` already
  does.

## QA-025: Unmapped DB errors return raw Postgres message, details, and hint
- **Severity:** low
- **Type:** security
- **Status:** confirmed-code
- **Area:** `backend/supabase/functions/_shared/responses.ts:66-76`
- **Other items in the same area:**
  - Webhook and scheduler secrets are compared with `!==`, not in constant time.
  - `rates_sync` accepts any HTTP method.
  - CORS is `*`.
- **Suggested fix:**
  - Return a generic `INTERNAL_ERROR` to clients and log the details server-side.
  - Compare secrets in constant time.
  - Allow `rates_sync` only on POST.

## QA-026: 5-minute subscription sync cooldown delays renewal and expiry in the UI
- **Severity:** low
- **Type:** improvement
- **Status:** confirmed-code
- **Area:** `client/lib/presentation/profile/bloc/profile_cubit.dart:34`, `:211`
- **Actual:** silent syncs from the listener or on resume are skipped for 5 minutes after the
  previous sync. An expiry can take up to 5 minutes to show while the app is open. Test
  subscriptions renew every 5 minutes, which makes this visible during device QA.
- **Suggested fix:** bypass the cooldown when `CustomerInfo` entitlements actually changed.

## QA-027: Currency picker is capped at 100 assets per kind
- **Severity:** low
- **Type:** improvement
- **Status:** confirmed-code
- **Area:** `client/lib/data/asset/data_source/supabase_asset_data_source.dart:40`, `:45`
- **Actual:** the client requests `limit: 100` and the server caps it at 100, with no
  pagination. That is fine while the catalog is the top 100, but it breaks silently if the catalog
  grows.
- **Suggested fix:** paginate, or have the server return the full active catalog per kind.

## QA-028: UX and architecture docs disagree with the current app
- **Severity:** low
- **Type:** docs
- **Status:** confirmed-code
- **Details:**
  - `docs/ux/screen-map.md`:
    - `/ds` is listed as public, but it requires auth;
    - `/splash` and `/base-currency` are missing;
    - `/paywall` is listed under Profile, but it is a top-level route.
  - `docs/ux/user_journeys.md`:
    - first launch is carousel → Sign up → first-auth paywall, not Sign in;
    - Set balance has no note field, and its date is fixed;
    - the upgrade flow is a custom paywall built on RevenueCat offerings, and only Customer Center
      uses the RevenueCat UI;
    - the explicit Save step for base currency is missing.
  - `docs/tech/client-architecture.md`:
    - it mentions a `user` presentation area and `data/account_asset/`, and neither exists;
    - `ContactDeveloperPage` calls the repository directly from the widget.
  - The `client/android/app/build.gradle.kts` comment says `google-services.json` is in
    `src/prod/`, but it is in `android/app/`.
  - `backend/README.md` says crypto is seeded from `supabase/seeds/crypto_top100_snapshot.tsv`,
    but `seed.sql` has it inline.
- **Suggested fix:** one docs-sync spec.

## QA-029: Free-plan downgrade keeps accounts and subaccounts above free limits
- **Severity:** info
- **Type:** improvement
- **Status:** confirmed-code
- **Area:** `api_apply_revenuecat_event` (`20260715130000`, lines 113-151)
- **Actual:**
  - After Pro expires, only the base currency is reset.
  - The user keeps, for example, 20 accounts and can still update balances in locked currencies.
    `set_balance` has no plan check.
  - They cannot create new items.
- **Suggested fix:** a product decision. Probably keep the current behavior (no data loss), but
  document it and show a "Pro expired" banner.

## QA-030: New profile has a null base asset; the client fills in USD
- **Severity:** info
- **Type:** improvement
- **Status:** confirmed-runtime (`qa/api/auth_profile.test.ts`)
- **Area:** `handle_auth_user_created` and `client/lib/domain/profile/usecase/ensure_profile_ready_usecase.dart`
- **Actual:** the profile trigger creates `base_asset_id = null`. The client then sets USD on first
  launch, which costs one extra request. If the client fails in between, the user runs with a null
  base asset (analytics falls back to USD, so this is harmless).
- **Suggested fix:** default `base_asset_id` to USD in the trigger and drop the client write.

## QA-031: Android toolchain cannot build on Java 25
- **Severity:** low
- **Type:** improvement
- **Status:** confirmed-runtime
- **Area:** `client/android/gradle/wrapper/gradle-wrapper.properties` (Gradle 8.14.3), `client/android/settings.gradle.kts` (AGP 8.11.1, Kotlin 2.2.20)
- **Actual:**
  - Gradle 8.14 runs only on Java 24 or older.
  - The machine's default JDK is Temurin 25, and `flutter config --jdk-dir` pointed to a missing `openjdk@17`. Android builds failed with "JAVA_HOME is set to an invalid directory".
  - The QA build now uses `flutter config --jdk-dir ~/.sdkman/candidates/java/21.0.9-tem`.
- **Suggested fix:**
  - After release, upgrade to Gradle 9.1+ plus an AGP version that supports it, and check Kotlin and plugin compatibility.
  - Or pin JDK 21 for the project with `org.gradle.java.home` or a `.sdkmanrc` with `java=21.0.9-tem`, so the toolchain does not depend on the machine default.
  - Also clean up the `source/target value 8 is obsolete` warnings coming from plugins.

## QA-032: 29 hardcoded English error messages are shown in the Russian UI
- **Severity:** medium
- **Type:** bug
- **Status:** confirmed-runtime. Seen with the ru locale: "Unable to load profile", "Unable to load accounts", "Unable to create account".
- **Area:** `fallbackMessage:` in every repository under `client/lib/data/**/repository/*.dart` (26 places). Also:
  - `presentation/auth/bloc/auth_cubit.dart:58`, `:257`;
  - `presentation/profile/bloc/profile_cubit.dart:70`;
  - the English paywall/limit snackbar texts ("Free plan position limit reached");
  - raw SDK messages, for example "Purchase failure simulated successfully in Test Store".
- **Expected:** every user-visible string goes through `app_en.arb`/`app_ru.arb`, as the project rules require.
- **Suggested fix:**
  - Make the data layer return failure **codes** only.
  - Map `code → l10n` in the presentation layer, with `errorGeneric` as the fallback.
  - Map `network` to a dedicated "No connection" string (together with QA-013).

## QA-033: Small UX and accessibility polish from the emulator pass
- **Severity:** low
- **Type:** ux
- **Status:** confirmed-runtime
- **Items:**
  1. The paywall close (X) button has no accessibility label, so it is empty in the semantics tree.
  2. Sign up submitted empty shows errors for email and password but not for Confirm password.
  3. Base currency screen: only the small `USD ⌄` chip opens the picker. Tapping the rest of the card does nothing.
  4. With base currency USD, subaccount and analytics rows repeat the same USD amount twice.
  5. The first history entry shows two bare `-` placeholders for "Implied change".
  6. The empty-state card on Main is focusable as one block, and a tap outside its button does nothing. A screen reader reads the whole card as one item.
  7. The error snackbar on sign-in lasts about 2 seconds, which is easy to miss.
  8. Subaccount rows show the balance twice even when the asset equals the base currency.
  9. Amount formatting drops trailing zeros: "250.5 USD" instead of "250.50 USD" (release build).
- **Suggested fix:** one UX-polish spec.

## QA-034: Paywall gives no explanation when the store is unavailable
- **Severity:** low
- **Type:** ux
- **Status:** confirmed-runtime (prod release build on an emulator with no Play account: `BILLING_UNAVAILABLE`)
- **Area:** `client/lib/presentation/paywall/page/paywall_page.dart`
- **Actual:**
  - Prices show `--`, Start Pro is disabled, and the legal line reads "-- / year".
  - Nothing tells the user why, or what to do (sign in to Google Play, update the Play Store).
  - The first-auth paywall is silently skipped, which is fine.
- **Suggested fix:** when offerings fail with `PurchaseNotAllowedError` or `BILLING_UNAVAILABLE`, show an inline message such as "Purchases are unavailable on this device. Make sure you are signed in to Google Play." together with Retry.
