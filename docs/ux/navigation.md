# Navigation

Navigation is centralized in `client/lib/core/routing`.

## Rules
- Route constants live in `AppRoutes`.
- Router construction lives in `app_router.dart`.
- Route guards live under `client/lib/core/routing/guards`.
- Auth and onboarding redirects are guard-driven, not scattered across pages.
- Pages should not manually redirect to `/sign-in` after auth changes; auth state changes should flow through the router refresh mechanism.
- Use `context.go(...)` for replacing the current location and `context.push(...)` for drilldown or modal-like flows.
- Completed-carousel launches start at internal `/splash` until auth resolves, then route to `/main` or `/sign-in`.

## Shell
The authenticated shell has three tabs:

1. Overview: `/main`
2. Analytics: `/analytics`
3. Profile: `/profile`

`StatefulShellRoute.indexedStack` preserves tab state.

Base currency settings are reachable as `/profile/base-currency` from Profile and as a pushed
`/base-currency` detail route from other authenticated screens.

## Route Extras
Use typed route extra objects from `client/lib/core/routing/route_extra_args.dart` when passing initial display data. Do not pass DTOs through route extras.
