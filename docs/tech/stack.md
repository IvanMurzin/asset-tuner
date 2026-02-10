# Asset Tuner — Tech Stack

**Last updated:** 2026-02-10

## Overview
Asset Tuner is a Flutter (iOS/Android) client backed by Supabase (Auth + Postgres + Edge Functions + scheduled jobs).

## Client (Flutter)
### Architecture (must follow)
Source of truth: `/Users/ivanmurzin/Projects/pets/asset_tuner/client/AGENTS.md`.

- Layered modules under `client/lib/`:
  - `core/` infra only (DI, routing, logging, config)
  - `core_ui/` design system (no feature deps)
  - `domain/` pure Dart (entities, repository contracts, use cases)
  - `data/` DTO/mappers/repos, Supabase integrations
  - `presentation/` UI + state (Cubit preferred); must not import `data/`

### State, routing, DI (fixed)
- State: `flutter_bloc` (Cubit preferred)
- Routing: `go_router` (`client/lib/core/routing`)
- DI: `get_it` + `injectable` (`client/lib/core/di`)

### Localization
- Supported locales: **English (`en`) + Russian (`ru`)**.
- Approach: Flutter `gen-l10n` (ARB files) with locale-aware number/date formatting.

### Offline behavior
- MVP is **online-first**.
- When offline, the app should degrade gracefully:
  - view-only using last-known cached summary (best-effort),
  - all mutations require network.

## Backend (Supabase)
### Supabase components used
- Auth: email OTP + Google OAuth + Apple OAuth
- Postgres: primary data store
- RLS: all user data isolated by `auth.uid()`
- Edge Functions: preferred API surface for write workflows and privileged operations
- Scheduled job (cron): hourly rates sync (FX + crypto) via Edge Function

### External data providers (rates)
- Fiat FX: OpenExchangeRates (server-side only)
- Crypto USD prices: CoinGecko (server-side only)

## Environments & configuration
- Environments: **dev + prod** (no staging in MVP).
- Client config is provided via `--dart-define-from-file` using local JSON files (not committed):
  - `.config.dev.json`
  - `.config.prod.json`

