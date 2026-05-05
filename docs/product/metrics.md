# Product Metrics

These metrics describe the product health signals agents should preserve when changing behavior.

## Activation
- User signs in successfully.
- Profile is ensured.
- User creates the first account.
- User creates the first subaccount.
- User sets the first balance.

## Engagement
- Overview opens with a non-empty total.
- Account detail opens from overview.
- Subaccount history opens.
- Analytics tab opens.
- Balance is updated at least once per week.

## Monetization
- Paywall viewed with reason.
- Purchase started.
- Purchase succeeded.
- Subscription refreshed.
- Plan changes from `free` to `pro` or back to `free`.

## Reliability
- Auth session restore succeeds.
- API calls fail with normalized error codes.
- Rates snapshot age stays within operational expectations.
- Crash-free sessions stay high in Firebase Crashlytics.
