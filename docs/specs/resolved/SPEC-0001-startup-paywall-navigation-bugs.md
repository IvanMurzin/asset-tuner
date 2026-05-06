# SPEC-0001: Startup Paywall Navigation Bugs

- **Type:** bug
- **Status:** Resolved
- **Priority:** P1
- **Owner:** codex
- **Created:** 2026-05-06
- **Resolved:** 2026-05-06

## Goal
Remove the restored-session login flash, keep base currency settings as a pushed detail flow
from Overview, and prevent the first-auth paywall from opening before profile data is ready.

## User Or Product Impact
Authenticated users should launch into the app without seeing transient auth screens, should
return to the same tab after changing base currency, and should not see generic errors caused by
paywall/profile readiness races.

## Current Behavior
The app starts completed-carousel users at `/sign-in`, then redirects authenticated sessions to
`/main` after auth resolves. The Overview base currency chip calls
`context.go(AppRoutes.baseCurrencySettings)`, which switches into the Profile branch. The first
auth paywall opens as soon as RevenueCat identity is ready, while `PaywallPage` shows a generic
error whenever profile state is not ready.

## Desired Behavior
Completed-carousel launches should start at an internal splash route until auth resolves. Restored
authenticated sessions should go directly to `/main`; unauthenticated sessions should go to
`/sign-in`. Overview base currency navigation should use a pushed settings route that preserves
the current tab. The onboarding paywall should open only after RevenueCat and profile are ready,
and profile loading inside paywall should render loading UI rather than an error.

## Scope
Client routing, Overview base currency navigation, first-auth paywall coordination, paywall
loading/error state, and focused tests.

## Out Of Scope
Backend contracts, RevenueCat product configuration, account/subaccount limits, localization copy,
and generated code.

## Constraints
Keep auth redirects centralized in `client/lib/core/routing`, use `context.push(...)` for
drilldown-like flows, do not add dependencies, and do not manually edit generated files.

## Implementation Notes
Add an internal `/splash` route and include it in public locations. Use it as the completed-carousel
initial route. Treat `/splash` like an auth-pending holding route in `AuthRouteGuard`, redirecting
to `/main` or `/sign-in` once resolved. Add a top-level authenticated base-currency route for push
navigation while preserving `/profile/base-currency`. Make `FirstAuthPaywallCoordinator` listen to
both `AuthCubit` and `ProfileCubit`; set onboarding-paywall seen only immediately before a real
open. Update `PaywallPage` profile `initial/loading` rendering to use the paywall loading skeleton.

## Acceptance Criteria
- [x] Restored authenticated cold start from `/splash` lands on `/main` without showing `/sign-in`.
- [x] Unauthenticated cold start from `/splash` lands on `/sign-in`.
- [x] Carousel-incomplete launches still stay on `/onboarding/carousel`.
- [x] Tapping Overview base currency opens settings via push and returns to Overview/Main on pop.
- [x] Profile base currency entry/deep link continues to work.
- [x] Onboarding paywall does not open or mark seen until RevenueCat and profile are ready.
- [x] Paywall shows loading UI while profile is initial/loading and error UI only on profile error.

## Verification
- `cd client && flutter analyze`
- `cd client && flutter test test/core/routing/app_router_integration_test.dart test/core/routing/first_auth_paywall_coordinator_test.dart test/presentation/settings/page/base_currency_settings_page_test.dart`
- `cd client && flutter test`

## Documentation Updates
Update `docs/ux/navigation.md` if route behavior changes need to be reflected after implementation.

## Rollout Notes
None.
