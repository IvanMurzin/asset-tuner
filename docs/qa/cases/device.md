# Device Cases (Android, owner-run)

The **owner** runs these on a real phone. They need a build from Google Play, a license-tester
Google account, or other owner-only access that an agent cannot use. The agent can watch the database in
parallel with the SQL helpers below and record the results in the run report.

These checks need a real phone, a build from Google Play, and a license-tester Google account.
They cannot be done on an emulator or with the dev flavor: dev uses the RevenueCat **Test Store**
key and never talks to Google Play Billing (`client/lib/core/config/app_config.dart:150-177`).

Run top to bottom. For each case, record ✅ / ❌ and the time. With the time, the matching rows in
`webhook_events` can be found. After each billing case, run the SQL under it, or ask Claude to
run it.

---

## 0. Preconditions (one-time)

### Google Play Console
- [ ] The app `developer.ivanmurzin.assettuner` exists. A **prod** AAB is uploaded to
      **Testing → Internal testing** and the release is rolled out. Build it with
      `flutter build appbundle --flavor prod --release --dart-define-from-file=../.config.prod.json`.
- [ ] **Monetize → Products → Subscriptions:**
  - the monthly and annual subscriptions exist and are **Active**;
  - each has an active base plan and a price in your test country.
- [ ] **Settings → License testing:**
  - your Google account is added;
  - "License response" is `RESPOND_NORMALLY`.
- [ ] **Internal testing → Testers:**
  - the same account is in the tester list;
  - you opened the opt-in link and accepted.
- [ ] **Monetize → Monetization setup:** Real-time developer notifications (RTDN) point to the
      RevenueCat Pub/Sub topic. RevenueCat shows the topic in Project settings → Google Play.

### RevenueCat
- [ ] **Project → Apps → Google Play:**
  - the package name is `developer.ivanmurzin.assettuner`;
  - service account credentials are uploaded and show **Valid**.
- [ ] **Product catalog:** both Play subscriptions are imported and attached to the Pro
      **entitlement**.
- [ ] That entitlement's **Identifier** is exactly the value of `REVENUECAT_PRO_ENTITLEMENTS` in the
      Supabase function secrets. The match is case-insensitive. A mismatch silently makes every
      subscriber `free`.
- [ ] **Offerings:** a `current` offering has a monthly and an annual package pointing to the Play
      products.
- [ ] **Integrations → Webhooks:**
  - the URL is `https://<project-ref>.supabase.co/functions/v1/revenuecat_webhook`;
  - the Authorization header value is `Bearer <REVENUECAT_WEBHOOK_SECRET>`;
  - "Send test event" returns **503**. That is expected: the dashboard test user has no profile.
- [ ] **Customer Center** is configured (Manage subscription opens it).

### Device
- [ ] The phone's **primary Google Play account** is the license tester.
- [ ] The dev flavor is uninstalled, to avoid QA-011's deep-link chooser. It is reinstalled later
      in D2.
- [ ] The app is installed **from the Play Store** through the internal testing link, not with
      `flutter install`. Play Billing does not work for sideloaded builds signed with a different key.

### Test accounts
Create two app users by signing up in the app with plus-addresses of your email. For example:
- **User A**: `you+qa-a@...`
- **User B**: `you+qa-b@...`

Delete them at the end (Profile → Delete account). Section 10 of `qa/sql/health.sql` only tracks
`qa+%@asset-tuner.test` users, so check these two separately.

### SQL helpers (read-only)
Run with `psql "$SUPABASE_DB_URL"` after `set -a; source backend/.env; set +a`, or in the SQL
editor. Replace `:email` with the app user's email.

```sql
-- S1: plan of a user
select u.email, p.plan, p.revenuecat_app_user_id, p.base_asset_id, p.updated_at
from auth.users u join public.profiles p on p.user_id = u.id
where u.email = ':email';

-- S2: billing ledger of a user (newest first)
select w.received_at, w.source, w.event_type, w.external_id
from public.webhook_events w
join auth.users u on w.app_user_id = u.id::text
where u.email = ':email'
order by w.received_at desc limit 20;
```

---

## 1. Purchases (P)

### P1. First purchase: monthly
1. Sign up as **User A**. The first-auth paywall opens automatically. Check it appears **exactly
   once**.
2. Select **Monthly** and tap **Continue**. The Google Play sheet shows the "Test card, always
   approves" option. Buy.
3. **Expected:**
   - the sheet closes;
   - the paywall closes **once** and you are on Overview, not a blank screen and not Sign in
     (QA-003);
   - the Profile badge shows Pro.
4. **DB:**
   - S1: `plan = pro`;
   - S2: an `INITIAL_PURCHASE` row from `revenuecat` within about 1 minute, plus a
     `revenuecat_refresh` row.
5. **Pro unlocks:**
   - create a 6th account, which succeeds;
   - pick a locked currency such as CAD or SOL for a subaccount, which succeeds;
   - set BTC as base currency, which succeeds.

### P2. Cancel and decline
1. As **User B** (free), open the paywall from Profile → Upgrade and tap Continue.
2. Close the Google Play sheet. **Expected:** nothing happens, with no error snackbar.
3. Try again and choose **"Test card, always declines"**. **Expected:** an error snackbar, and
   User B stays free (S1).

### P3. Pending payment (QA-006)
1. As **User B**, buy with **"Slow test card, approves after a few minutes"**.
2. **Expected:** a neutral "pending" message. **Current behavior:** an error snackbar (QA-006).
   Record exactly what you see (screenshot).
3. Wait about 3–5 minutes with the app open, then put it in the background and bring it back.
   **Expected:** Pro activates without any action from you. S2 shows `INITIAL_PURCHASE`.
4. Repeat with **"Slow test card, declines after a few minutes"** on a fresh user, or after P5
   expiry. **Expected:** the user stays free, and no lasting error is left on screen.

### P4. Paywall entry points (single pop, QA-003)
With a **free** user, open the paywall from each entry point and buy. Between runs, cancel in
Play and wait for expiry, or use a fresh user. The minimum is the first two rows.

| Entry point | How to open | Expected after purchase |
|---|---|---|
| Account limit | Create a 6th account | Back on the Create account form |
| Locked currency | Add subaccount → tap a locked currency | Back on the Add subaccount form |
| Base currency | Profile → Base currency → locked currency | Back on Base currency. Check whether the currency is applied (QA-021). |
| Profile | Profile → Upgrade | Back on Profile |

If a screen underneath is popped too, for example you land on Overview instead of the form,
QA-003 is confirmed.

## 2. Subscription lifecycle (L)
With license testers, subscription periods are accelerated. **Monthly renews every 5 minutes**
and auto-cancels after 6 renewals. Annual renews every 30 minutes.

### L1. Renewals
1. After P1, keep User A subscribed for about 15 minutes.
2. **DB:** S2 shows `RENEWAL` rows about every 5 minutes, and S1 stays `pro`.
3. The app stays Pro after a restart.

### L2. Cancel → expire
1. As User A: Profile → Manage subscription → Customer Center → cancel. Or cancel in the Play
   Store → Subscriptions.
2. **Expected right away:**
   - the user is still Pro;
   - S2 shows a `CANCELLATION` row;
   - S1 is still `pro`.
3. Set the base currency to a locked one first, such as BTC, so the downgrade reset is visible.
4. After the current period ends (at most about 5 minutes):
   - S2 shows `EXPIRATION`;
   - S1 shows `plan = free` and `base_asset_id` back to USD.
5. In the app, pull to refresh on Profile. It shows Free, Overview totals are in USD, and existing
   accounts are still visible (QA-029).
6. Note how long the app took to show Free without a pull-to-refresh (QA-026).

### L3. Resubscribe and change plan
1. Resubscribe to Monthly. **Expected:** Pro.
2. Switch from Monthly to Annual, from the paywall or the Play Store. **Expected:** S2 shows
   `PRODUCT_CHANGE`, and the plan stays Pro throughout.

### L4. Billing problem (optional, 10 minutes)
1. In Play Store → Payments, switch the tester's payment method to a test card that
   **declines**, then wait for a renewal.
2. **Expected:**
   - S2 shows `BILLING_ISSUE`;
   - the user stays Pro during the grace period;
   - after grace or account hold, `EXPIRATION` arrives and the plan becomes free.

## 3. Restore and identity (R)

### R1. Reinstall and restore
1. User A is Pro. Uninstall the app, install it again from Play, and sign in as User A.
2. **Expected:** Pro right after sign-in, without pressing Restore.
3. Press Restore on the paywall or in Manage subscription anyway. **Expected:** a success message
   and still Pro.

### R2. Another app user on the same Google account (QA-007)
1. Sign out, then sign in as **User B** (free) on the same phone and Google account.
2. **Expected before restore:** User B is **free**. Pro must not carry over from User A's session.
   S1 for B shows `free`.
3. Press **Restore**. RevenueCat moves the purchase to B, which is the default "transfer" behavior.
4. **Check:**
   - B becomes Pro;
   - S1 for **A** becomes `free`;
   - S2 shows the `TRANSFER` handling.

   If A stays `pro` in the DB and S2 has no row for the transfer, QA-007 is confirmed.
5. Sign back in as A and note the plan A sees.

### R3. Delete account while subscribed
1. User A is Pro. Profile → Delete account → confirm.
2. **Expected:** the user is signed out and the account is gone.
3. **Note:**
   - does the app warn that the Play subscription continues and must be cancelled in Play?
   - S1 for A after deletion: does the profile still exist? (QA-002)
4. Cancel the Play subscription manually afterwards.

## 4. Auth and deep links on a device (D)

### D1. Google sign-in
1. Sign out, then Sign in → Google → choose the account. **Expected:** you land in the app,
   signed in.
2. Sign out, start Google sign-in, and **close the Custom Tab** without choosing an account.
   **Expected:** the buttons are usable again right away. Currently they may be disabled for
   90 seconds (QA-008).
3. Tap **Apple** and note what happens on Android (QA-012).

### D2. Both flavors installed (QA-011)
1. Install the dev flavor (`flutter install --flavor dev`) next to the prod app from Play.
2. Start Google sign-in in **prod**. **Expected:** the callback returns to prod with no app
   chooser. Record whether a chooser appeared or the wrong app opened.
3. Uninstall dev afterwards.

## 5. Release-build smoke (S)
These run on the Play-installed prod build, to catch R8/minify issues the emulator debug build
cannot show.
- [ ] Cold start, then sign in with email.
- [ ] Create an account, add a USD and a BTC subaccount, update a balance, view history.
- [ ] Open Analytics; open Overview with base currency EUR.
- [ ] Switch the language to Russian, then back.
- [ ] Contact developer: send one message.
- [ ] Kill the app and relaunch. The session is restored with no sign-in prompt.
- [ ] No crash reports in Firebase Crashlytics for the session.

## 6. Owner-Only Extras (X)

### X1. Negative amounts on your keyboard (QA-015)
Gboard on the emulator shows `-` on the numeric layout. Check the keyboard you actually use,
Samsung Keyboard in particular:
1. Add subaccount → Amount → try typing `-100,50`.
2. **Expected:** the minus and the comma or dot can be typed, and the value saves as `-100.50`.

### X2. Real-device performance and feel
With about 10 accounts and 30 subaccounts, seeded with `qa/emulator/user_api.ts`:
1. Cold start to Main in under about 3 seconds on your phone.
2. Scrolling Main, Account detail and Analytics shows no visible jank.
3. Back navigation feels right everywhere (gesture navigation), with no accidental app exits.

### X3. Store listing sanity
- [ ] Play listing screenshots match the current UI in English and Russian.
- [ ] The Privacy policy URL on the listing matches `PRIVACY_POLICY_URL`.
- [ ] The Data safety form matches actual behavior: after QA-002 is fixed, data is deleted with
      the account.
- [ ] Google Play's account deletion web link is provided. Play requires a URL for deletion
      requests outside the app.

## 7. Cleanup
- [ ] Cancel every active test subscription (Play Store → Subscriptions).
- [ ] Delete User A and User B in the app, or ask Claude to hard-delete them.
- [ ] Run `qa/sql/health.sql`. Section 7 should not list your test users as Pro.
