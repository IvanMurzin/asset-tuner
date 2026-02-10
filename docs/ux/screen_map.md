# Screen map (MVP)

This map enumerates user-facing screens used by MVP features `docs/features/FTR-001..009`.

Notes:
- All “Copy” in screen specs is written in English as the source string; implementation must localize via `AppLocalizations` per FTR-002.
- Components listed as “needs component” are gaps in `client/lib/core_ui/` design system and should be designed/implemented before feature UI is built.

## Navigation model (MVP)
- App starts at `SCR-001` (session restore).
- If unauthenticated → `SCR-002` (Sign-in).
- After sign-in:
  - optional onboarding step `SCR-003` (base currency confirmation)
  - then `SCR-004` (Overview) as the primary hub.
- From Overview:
  - Accounts list (`SCR-005`) is reachable via top-level navigation.
  - Settings (`SCR-009`) is reachable via top-level navigation.

## Screens

| Screen ID | Name | Type | Primary entry points | MVP features |
|---|---|---|---|---|
| SCR-001 | Splash / Session restore | Full screen | App launch | FTR-001 |
| SCR-002 | Sign-in | Full screen | Unauthenticated start; sign-out | FTR-001, FTR-002 |
| SCR-003 | Onboarding: Base currency | Full screen | First sign-in (optional) | FTR-001, FTR-003, FTR-009 |
| SCR-004 | Overview | Full screen | Post-auth default | FTR-003, FTR-006, FTR-007, FTR-008, FTR-002 |
| SCR-005 | Accounts list | Full screen | Top-level nav from Overview | FTR-004, FTR-009, FTR-002 |
| SCR-006 | Account form (create/edit) | Full screen | Create/edit account actions | FTR-004, FTR-009, FTR-002 |
| SCR-007 | Account detail | Full screen | Tap account from Overview/Accounts list | FTR-004, FTR-005, FTR-008, FTR-002 |
| SCR-008 | Add asset (catalog search) | Full screen / modal | “Add asset” from Account detail | FTR-005, FTR-009, FTR-002 |
| SCR-009 | Settings | Full screen | Top-level nav from Overview | FTR-003, FTR-009, FTR-002 |
| SCR-010 | Asset position detail (history) | Full screen | Tap asset position from Account detail | FTR-006, FTR-008, FTR-002 |
| SCR-011 | Add balance (snapshot/delta) | Full screen / modal | “Add balance” from Asset position detail | FTR-006, FTR-002 |
| SCR-012 | Base currency settings | Full screen | From Settings | FTR-003, FTR-009, FTR-002 |
| SCR-013 | Paywall | Full screen / modal | Gated actions (accounts/positions/base currency) | FTR-009, FTR-003, FTR-004, FTR-005 |
| SCR-014 | Manage subscription | Full screen | From Settings or Paywall | FTR-009, FTR-002 |

## Acceptance Criteria coverage (feature → screens/states)

Conventions:
- AC IDs below are locally numbered per feature in the order they appear in `docs/features/*`.
- “State” refers to a named UI state inside a screen (loading/empty/error/success).

### FTR-001: Authentication and profile bootstrap
| AC | Coverage (screen → state) |
|---|---|
| FTR-001.AC1 (unauthenticated shows Sign-in) | `SCR-001` → unauthenticated routing; `SCR-002` → default state |
| FTR-001.AC2 (request email OTP + check email state) | `SCR-002` → submit success (“Check your email”) |
| FTR-001.AC3 (OTP verified → next step or Overview) | `SCR-002` → verification success → `SCR-003` or `SCR-004` |
| FTR-001.AC4 (Google/Apple configured behaves same) | `SCR-002` → OAuth success → `SCR-003`/`SCR-004` |
| FTR-001.AC5 (session restored after restart) | `SCR-001` → session restore success |
| FTR-001.AC6 (profile bootstrap + base currency default USD) | `SCR-001`/`SCR-002` → post-auth bootstrap loading; `SCR-003`/`SCR-004` depends on routing |
| FTR-001.AC7 (normalized Failure mapping) | All screens → error states use mapped failure codes/messages |

### FTR-002: Localization (en + ru)
| AC | Coverage (screen → state) |
|---|---|
| FTR-002.AC1 (English strings) | All screens → all states |
| FTR-002.AC2 (Russian strings) | All screens → all states |
| FTR-002.AC3 (locale number formatting) | `SCR-004`, `SCR-007`, `SCR-010` → success states with totals/amounts |
| FTR-002.AC4 (locale date formatting) | `SCR-010` history list; `SCR-004` rates timestamp |
| FTR-002.AC5 (missing translations detected) | Build/CI gate (non-screen); UX impact: no runtime fallback strings allowed |

### FTR-003: Base currency settings (free vs paid)
| AC | Coverage (screen → state) |
|---|---|
| FTR-003.AC1 (default USD for new user) | `SCR-001` post-auth bootstrap; verified on `SCR-003`/`SCR-012` initial selection |
| FTR-003.AC2 (free can save USD/EUR/RUB) | `SCR-012` → save success |
| FTR-003.AC3 (free selecting other shows paywall; no change) | `SCR-012` → gated selection → `SCR-013` (reason “base currency”) |
| FTR-003.AC4 (paid can save any fiat; overview recalculates) | `SCR-012` → save success; `SCR-004` → totals recomputed |
| FTR-003.AC5 (fiat catalog load failure shows retryable error) | `SCR-012` → error state with retry |

### FTR-004: Accounts CRUD
| AC | Coverage (screen → state) |
|---|---|
| FTR-004.AC1 (create account appears in list) | `SCR-006` → create success; `SCR-005`/`SCR-004` → list refresh |
| FTR-004.AC2 (edit persists across refresh) | `SCR-006` → edit success; `SCR-005`/`SCR-007` → reflects after refresh |
| FTR-004.AC3 (archive hides from default totals; unarchive available) | `SCR-005` → archived section; `SCR-004` → excludes by default |
| FTR-004.AC4 (delete calls edge function; cascades) | `SCR-007`/`SCR-005` → delete confirm → loading → success |
| FTR-004.AC5 (delete failure shows retryable error) | `SCR-007`/`SCR-005` → delete error state (retry) |

### FTR-005: Supported assets inside accounts
| AC | Coverage (screen → state) |
|---|---|
| FTR-005.AC1 (Add asset loads catalog + search) | `SCR-008` → loading/success |
| FTR-005.AC2 (confirm creates position shown in account) | `SCR-008` → add success; `SCR-007` → list updated |
| FTR-005.AC3 (prevent duplicates with validation error) | `SCR-008` → validation error state |
| FTR-005.AC4 (free exceeding positions shows paywall; blocks add) | `SCR-008` → gated confirm → `SCR-013` (reason “asset positions limit”) |
| FTR-005.AC5 (remove asset removes position from totals) | `SCR-007` → remove confirm → success; `SCR-004` totals update |

### FTR-006: Balance entries (snapshot + delta) with history
| AC | Coverage (screen → state) |
|---|---|
| FTR-006.AC1 (form supports type/date/amount) | `SCR-011` → default state |
| FTR-006.AC2 (snapshot submits; implied delta; refresh) | `SCR-011` → submit success; `SCR-010` → refreshed history |
| FTR-006.AC3 (delta submits; history reflects) | `SCR-011` → submit success; `SCR-010` → refreshed history |
| FTR-006.AC4 (multi-device consistency) | `SCR-010` → refresh state; history is server-source-of-truth |
| FTR-006.AC5 (history paginated and sorted) | `SCR-010` → pagination loading states |
| FTR-006.AC6 (validation failure highlights field) | `SCR-011` → validation error state (inline) |

### FTR-007: Server-cached rates (hourly) and timestamp
| AC | Coverage (screen → state) |
|---|---|
| FTR-007.AC1 (hourly job updates rates) | User-visible confirmation via `SCR-004` rates timestamp after refresh |
| FTR-007.AC2 (failed sync keeps prior rates) | `SCR-004` → stale timestamp + totals still computed from last-known rates |
| FTR-007.AC3 (client reads latest usd_price + as_of) | `SCR-004` → loading/success (rates loaded) |
| FTR-007.AC4 (overview shows “Rates updated at …” localized) | `SCR-004` → success; formatting per locale |

### FTR-008: Overview totals, breakdown, drill-down (missing-rate behavior)
| AC | Coverage (screen → state) |
|---|---|
| FTR-008.AC1 (overview displays totals + timestamp) | `SCR-004` → success |
| FTR-008.AC2 (all holdings priced totals sum correctly) | `SCR-004` → success (priced) |
| FTR-008.AC3 (missing rates → partial + N/A + unpriced list) | `SCR-004` → missing-rate success state |
| FTR-008.AC4 (account detail shows original + converted/unpriced) | `SCR-007` → success |
| FTR-008.AC5 (offline shows cached snapshot or offline state) | `SCR-004` → offline cached success; offline empty/error |
| FTR-008.AC6 (Decimal math for totals) | `SCR-004`/`SCR-007` → success (calculation requirement; display rounding only) |

### FTR-009: Freemium limits, entitlements, and paywall UX
| AC | Coverage (screen → state) |
|---|---|
| FTR-009.AC1 (accounts limit paywall blocks create) | `SCR-006` → gated save → `SCR-013` (reason “accounts limit”) |
| FTR-009.AC2 (positions limit paywall blocks add) | `SCR-008` → gated confirm → `SCR-013` (reason “asset positions limit”) |
| FTR-009.AC3 (base currency paywall blocks selection) | `SCR-012` → gated selection → `SCR-013` (reason “base currency”) |
| FTR-009.AC4 (purchase success refreshes entitlements unlocks) | `SCR-013` → purchase success; return-to-context and retry |
| FTR-009.AC5 (cannot verify entitlements → treat as free; non-blocking message when blocked) | `SCR-013` → “Couldn’t verify subscription; try again” inline banner; gated actions remain blocked |
| FTR-009.AC6 (cancel/expire returns to free for new actions; existing data visible) | `SCR-004`/`SCR-005`/`SCR-007` → existing data visible; `SCR-006`/`SCR-008`/`SCR-012` → gating applies |
