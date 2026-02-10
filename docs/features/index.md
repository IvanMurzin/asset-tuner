# Features index (MVP)

This folder contains **testable feature specs** for coding agents.

Sources of truth (do not duplicate here; follow them):
- Product truth: `docs/prd/*`
- Tech truth: `docs/tech/*`, `docs/adr/*`

## MVP feature list
Priorities:
- **P0** = required for MVP

| ID | Feature | Priority | Depends on |
|---|---|---:|---|
| FTR-001 | [Authentication and profile bootstrap](FTR-001-auth-and-profile.md) | P0 | — |
| FTR-002 | [Localization (en + ru)](FTR-002-localization-en-ru.md) | P0 | — |
| FTR-009 | [Freemium limits, entitlements, and paywall UX](FTR-009-freemium-entitlements-and-paywall.md) | P0 | FTR-001 |
| FTR-003 | [Base currency settings (free vs paid)](FTR-003-base-currency-settings.md) | P0 | FTR-001, FTR-009 |
| FTR-004 | [Accounts CRUD (create/edit/archive/delete)](FTR-004-accounts-crud.md) | P0 | FTR-001 |
| FTR-005 | [Supported assets inside accounts](FTR-005-assets-in-accounts.md) | P0 | FTR-001, FTR-004, FTR-009 |
| FTR-006 | [Balance entries (snapshot + delta) with history](FTR-006-balance-entries-snapshot-and-delta.md) | P0 | FTR-005 |
| FTR-007 | [Server-cached rates (hourly) and rates timestamp](FTR-007-rates-sync-and-rates-read.md) | P0 | — |
| FTR-008 | [Overview totals, breakdown, drill-down](FTR-008-overview-totals-and-drilldown.md) | P0 | FTR-003, FTR-006, FTR-007 |

## Notes
- Requirements mapping is defined in `docs/prd/requirements.md` (FR-001..FR-074).
- Edge Functions are preferred for writes (see `docs/adr/ADR-0002-edge-functions-api.md` and `docs/tech/api_assumptions.md`).
- Money arithmetic must use Decimal (see `docs/adr/ADR-0004-decimal-precision.md`).

