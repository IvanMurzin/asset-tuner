# Screen Map

The app uses `go_router` and the route constants in `client/lib/core/routing/app_routes.dart`.

## Public Flow
Public routes are `AppRoutes.publicLocations`.

| Route | Screen | Purpose |
|---|---|---|
| `/splash` | Splash | Startup while the session and profile resolve. |
| `/onboarding/carousel` | Onboarding carousel | First-run product introduction; leads to Sign up. |
| `/sign-up` | Sign up | Email/password registration. |
| `/sign-in` | Sign in | Email/password and configured OAuth sign-in. |
| `/otp` | OTP | Email verification flow. |

## Authenticated Shell
The authenticated app uses `StatefulShellRoute.indexedStack`.

| Route | Tab | Purpose |
|---|---|---|
| `/main` | Overview | Global total, account list, rates timestamp, drilldown. |
| `/analytics` | Analytics | Asset breakdown and update feed. |
| `/profile` | Profile | Settings, subscription, archived accounts, support, sign-out. |

## Account Routes
| Route | Purpose |
|---|---|
| `/main/accounts/new` | Create account. |
| `/main/accounts/:accountId` | Account detail and subaccounts. |
| `/main/accounts/:accountId/edit` | Edit account name/type. |
| `/main/accounts/:accountId/subaccounts/new` | Create subaccount. |
| `/main/accounts/:accountId/subaccounts/:subaccountId` | Subaccount detail and history. |
| `/main/accounts/:accountId/subaccounts/:subaccountId/update-balance` | Set current balance. |

## Profile Routes
| Route | Purpose |
|---|---|
| `/profile/base-currency` | Base asset selection (from Profile). |
| `/profile/subscription` | Manage subscription entry point. |
| `/profile/archived-accounts` | Archived account list. |
| `/profile/archived-accounts/:accountId` | Archived account detail. |
| `/profile/contact-developer` | Support message form. |

## Top-Level Pushed Routes
Pushed over the shell; they require authentication.

| Route | Purpose |
|---|---|
| `/paywall` | Custom Pro paywall built on RevenueCat offerings (`PaywallArgs.reason` sets the copy). |
| `/base-currency` | Base asset selection pushed from Overview. |
| `/ds` | Internal design system preview. |
