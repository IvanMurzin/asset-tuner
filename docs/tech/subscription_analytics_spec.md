# Subscription Analytics Spec

## Purpose
Measure the subscription funnel without logging private financial data. RevenueCat remains the source of truth for subscription revenue and lifecycle. Product analytics tracks funnel behavior, placement performance, and activation signals.

## Providers
- Firebase/GA4: acquisition, first-session funnel, audiences, campaign attribution, product events.
- RevenueCat: subscription revenue, cohorts, entitlements, offering/paywall performance.
- BigQuery export: later, when paid acquisition starts and cohort analysis needs raw event joins.

## Identity
- Before auth: anonymous app instance identity only.
- After auth: set analytics user ID to Supabase `userId`.
- RevenueCat App User ID must match Supabase `userId`.
- User properties:
  - `plan`: `free` or `pro`
  - `locale`
  - `platform`
  - `app_version`
  - `onboarding_version`
  - `paywall_variant`
  - `auth_provider`, only after successful auth
- Never log emails, names, account names, wallet names, balances, raw portfolio values, transaction-like details, tokens, or secrets.

## Events
- `onboarding_started {version}`
- `onboarding_slide_viewed {version, slide_index}`
- `onboarding_completed {version}`
- `auth_started {entry_point, method}`
- `auth_completed {entry_point, method}`
- `auth_failed {entry_point, method, failure_code}`
- `paywall_viewed {placement, reason, variant, selected_plan}`
- `paywall_dismissed {placement, reason, variant}`
- `plan_selected {placement, plan, package_id}`
- `purchase_started {placement, reason, plan, package_id}`
- `purchase_succeeded {placement, reason, plan, package_id}`
- `purchase_failed {placement, reason, plan, package_id, failure_code, cancelled}`
- `restore_started {placement}`
- `restore_succeeded {placement}`
- `restore_failed {placement, failure_code}`
- `subscription_sync_started {source}`
- `subscription_sync_succeeded {source, plan}`
- `subscription_sync_failed {source, failure_code}`
- `account_created {account_type}`
- `subaccount_created {asset_kind}`
- `balance_updated {asset_kind}`
- `base_currency_changed {currency_group}`
- `limit_hit {reason}`
- `locked_feature_tapped {reason}`
- `manage_subscription_opened {plan}`
- `customer_center_opened {plan}`
- `customer_center_closed {plan}`

## Revenue Rules
- Do not manually log purchase revenue into GA4 unless duplicate automatic IAP tracking has been ruled out.
- Custom purchase events are funnel events, not revenue-source events.
- Use RevenueCat dashboards/webhooks for revenue, refunds, renewals, cancellations, grace periods, and entitlement state.

## Dashboards
- First-session funnel: `first_open -> onboarding_completed -> auth_completed -> paywall_viewed -> purchase_started -> purchase_succeeded`.
- Placement funnel: onboarding paywall vs feature-gate paywall vs manage-subscription paywall.
- Plan mix: annual selected, monthly selected, annual purchase share.
- Drop-off: onboarding slides, auth methods, paywall dismissals, purchase cancels/errors.
- Monetization: D0/D1/D7 paid conversion, RPI, conversion by locale/platform/source.
- Retention: free vs Pro D7/D30, cancellation and expiration cohorts from RevenueCat.
