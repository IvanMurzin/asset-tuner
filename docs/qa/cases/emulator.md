# Emulator Cases

An agent runs these on the Android emulator with the **dev** flavor, where purchases go through
the RevenueCat **Test Store** (no Google Play), and drives the app with `qa/emulator/ui.py`. Each
case lists its setup, steps, and expected result. Record the results in a run report under
`docs/qa/runs/`.

Case ids are stable: add new cases at the end and never renumber. A case that needs a real phone
or the owner's accounts belongs in `device.md`.

## Conventions
- **QA user:** sign up in the app with `qa+emu-<unix-ts>@asset-tuner.test` and a generated
  password. Keep the credentials in a scratch file outside the repository (email on line 1,
  password on line 2). `qa/emulator/user_api.ts` uses that file to seed data.
- **Second user:** some cases need a fresh free user. Create `qa+emu2-<ts>@…` the same way.
- **Record user ids** before deleting anything in the UI. The app's delete flow scrambles the
  email (QA-002), so run `select id, email from auth.users where email like 'qa+%'` first.
- **Evidence:** a screenshot for every `fail`, and a log excerpt (`ui.py logs <pattern>`) when
  the problem is not visible on screen.
- **Findings:** when a case hits a known finding, cite its `QA-NNN`. Append anything new to
  `docs/qa/findings.md`.

## Core Flows

### E1: First launch and sign up
1. Fresh install. Step through the carousel with Continue, then Get started.
2. Sign up with all fields empty. Expect errors on email and password.
3. Enter an invalid email, a weak password (`abc`) and a mismatched confirm password. Expect three
   errors.
4. Sign up with valid data. Expect the first-auth paywall to appear **once**, with no subtitle
   about limits.
5. Tap Continue with Free. Expect Main with a total of 0 USD and the guided tour at Step 1 of 3.

### E2: Sign out, sign in, session restore
1. Profile → Sign out → confirm. Expect the Sign in screen.
2. Sign in with a wrong password. Expect an "Invalid credentials" snackbar, localized.
3. Sign in with the correct password. Expect Main, and **no** first-auth paywall again.
4. Force-stop and relaunch the app. Expect Main without a sign-in prompt.

### E3: Overview empty state and tour
1. Go through the tour with Next and Finish. Expect it not to come back after a relaunch.
2. Pull to refresh. Expect no error.

### E4: Create account
1. Tap Add account and Save with an empty name. Expect "Name is required".
2. Enter a name and type Bank, then Save. Expect the account detail page, and the account listed on Main.

### E5: Create subaccount
1. Account → Add subaccount. The currency picker defaults to USD.
2. Picker: Fiat and Crypto tabs; searching `bit` finds BTC.
3. Enter the amount on the **on-screen keyboard** as `-1234,56` (negative sign and comma
   separator). Expect it to be saved as `-1,234.56 USD`.
4. Create a BTC subaccount with `0,015`. Check the USD conversion against the rate shown in the
   picker.

### E6: Set balance and history
1. Save the same value. Expect "Balance is unchanged".
2. Save a new value. Expect the history row with the correct implied change and sign.

### E7: Subaccount limit leads to the paywall
1. Seed the account to 15 subaccounts:
   `deno run --allow-net --allow-read qa/emulator/user_api.ts <creds> seed-subaccounts "<account>" 14`.
2. Add a 16th subaccount. Expect the paywall with the subtitle "reached the free limit of 15
   subaccounts", and **no** error snackbar underneath (QA-023).

### E8: Test Store purchase from the subaccount limit
1. From the E7 paywall, tap Start Pro, then Cancel. Expect nothing to happen.
2. Start Pro, then Test failed purchase. Expect a localized error.
3. Start Pro, then Test valid purchase. Expect to return to the **Add subaccount form** (QA-003),
   with the Pro badge in Profile.
4. DB: `profiles.plan = pro`, plus an `INITIAL_PURCHASE` row in `webhook_events` (SANDBOX, TEST_STORE).
5. As Pro, the 16th subaccount and a locked currency are allowed.

### E9: Paywall error or loading state can be closed
1. Turn the network off (`ui.py net off`) and force-stop the app, then relaunch it and open
   Profile → Upgrade.
2. Expect a visible close button in every paywall state (QA-010).

### E10: Base currency
1. Profile → Base currency. Tap the currency **chip**, choose EUR, then Save.
2. Expect the Main total in EUR, with conversion equal to total USD divided by the EUR rate.
3. On the free plan, pick a locked currency such as CAD. Expect the paywall.

### E11: Analytics
1. Empty user: expect the "No analytics yet" card. Its Add account button should switch to the
   New account form.
2. With data: expect the breakdown percentages to add up to 100 and the feed to show the latest
   balance change.

### E12: Offline behavior
1. While signed in, turn the network off and do a cold start. Expect an inline error with Retry,
   a **localized** "no connection" message (QA-013, QA-032), and no crash (QA-009).
2. Offline, try to create an account. Expect a localized error and the form kept.
3. Turn the network on and retry. Expect every section to recover.

### E13: Server-side session revoke, then sign in again
1. `deno run --allow-net --allow-read qa/emulator/user_api.ts <creds> revoke-sessions`.
2. Pull to refresh. Expect the Sign in screen.
3. Sign in as the **same** user. Expect Main within about 5 seconds, not stuck on Sign in (QA-005).

### E14: Cancel Google OAuth
1. On Sign in, tap Continue with Google. The browser opens; do not enter credentials.
2. Return to the app, using back or the app switcher.
3. Expect the sign-in buttons to be usable within about 2 seconds (QA-008), and no pile of
   leftover Chrome tabs.

### E15: Localization and theme
1. Switch the language to Russian, then visit Main, Analytics, Profile, the paywall, a form, and an
   error state. Record any English text.
2. Switch the theme to Dark and back to Light. Check the same screens for contrast and
   readability.

### E16: Contact developer and delete account
1. Contact developer: sending an empty message shows a validation error; a valid send shows a
   thank-you snackbar.
2. Record the user id. Then Profile → Delete account → confirm. Expect the Sign in screen.
3. DB: the user's profile, accounts and subaccounts must be **gone** (QA-002). Check the copy
   under the button and in the dialog.

### E17: Prod release build smoke
1. Build with
   `flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json`, then
   install.
2. Sign up, create an account and a subaccount, set a balance, open Analytics. Expect no crash
   and no `FATAL EXCEPTION` in logcat.
3. Open the paywall. Without Play billing, prices show `--`. Check the explanation text (QA-034)
   and the subtitle (QA-022).

## Added After Run 2026-09-24

These cases were not covered on the emulator in the first run.

### E18: Edit account
1. Account detail → Edit. Rename the account and change its type to Exchange, then Save.
2. Expect the new name and type on the detail page and on Main, grouped under the new type.
3. Save with an empty name. Expect a validation error.

### E19: Archive and unarchive an account
1. Account detail → Archive → confirm. Expect the account gone from Main and the Main total
   lowered.
2. Profile → Archived accounts. Expect the account listed. Open it: read-only, with Edit and
   Delete hidden.
3. Unarchive. Expect to land back, with the account on Main again and the total restored.
4. Note whether an archived account can be deleted; per the code it cannot.

### E20: Delete an account
1. Account detail → Delete. The dialog shows; Cancel keeps the account.
2. Delete → confirm. Expect it removed from Main, the total updated, and Analytics no longer
   counting it.

### E21: Rename and delete a subaccount; Android back
1. Subaccount detail → Rename in the bottom sheet. An empty name is rejected; a valid name shows
   up in the header and the account list.
2. Subaccount detail → Delete → confirm. Expect it gone and the account total updated.
3. From the subaccount detail, press **Android back** (hardware or gesture). Expect the account
   detail page, not an app exit or a no-op (the page uses `PopScope(canPop: false)`).

### E22: History pagination
1. Seed 60 balance entries:
   `deno run --allow-net --allow-read qa/emulator/user_api.ts <creds> seed-history "<account>" "<subaccount>" 60`.
2. Open the subaccount and scroll to the bottom of the history. Tap Load more.
3. Expect every entry exactly once, newest first, with no duplicates at the page boundary.

### E23: Account limit leads to the paywall; purchase returns to the form
1. On a **fresh free user**, seed 5 accounts:
   `deno run --allow-net --allow-read qa/emulator/user_api.ts <creds> seed-accounts 5`.
2. Add a 6th account. Expect the paywall with the account-limit subtitle.
3. Test valid purchase. Expect to return to the **Create account** form (QA-003). Save works.

### E24: Other paywall entry points (Test Store)
Use a fresh free user for each entry point, or cancel the purchase.

| Entry point | How to open | Expected subtitle | Expected after a valid purchase |
|---|---|---|---|
| Locked currency | Add subaccount → currency picker → a locked item such as CAD | Currency-specific | Back on the Add subaccount form |
| Locked base currency | Profile → Base currency → CAD | Base-currency | Back on Base currency; CAD applied or pre-selected (QA-021) |
| Profile Upgrade | Profile → Upgrade plan | Generic, **not** "Unlock any base currency" (QA-022) | Back on Profile, Pro badge |
| Manage subscription | Profile → Manage subscription → Upgrade | Generic | Back on Manage subscription |

### E25: Restore purchases (Test Store)
1. As the Pro user from E8, sign out and sign in again, then open Profile → Manage subscription → Restore.
   Expect a success message and Pro kept.
2. As a fresh free user, open the paywall → Restore. Expect a clear "nothing to restore" message
   and the user still free. Record the exact text.

### E26: Manage subscription page
1. Pro user: Profile → Manage subscription. Expect the plan card and feature list. Manage opens
   the RevenueCat Customer Center, or shows a clear message when unsupported in Test Store.
2. Free user: the page shows Upgrade and Restore, and no crash.

### E27: Onboarding skip and legal links
1. Fresh install. Tap Skip on the first slide. Expect the last slide or Sign up, with no
   flicker loop.
2. Tap the Terms and Privacy links on Sign up and on the paywall. Expect them to open in the
   browser with the correct URLs.

### E28: Profile pull to refresh
1. Pull to refresh on Profile, as a Pro user and as a free user.
2. Expect no error snackbar and the plan badge unchanged. The logs show a subscription sync.
