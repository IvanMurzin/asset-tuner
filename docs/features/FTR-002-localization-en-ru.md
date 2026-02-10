# FTR-002: Localization (en + ru)

## Summary
Provide English and Russian UI using Flutter `gen-l10n`, with locale-aware number/date formatting across screens.

Source references:
- Product: `docs/prd/prd.md`
- Tech: `docs/tech/stack.md`
- ADRs: `docs/adr/ADR-0001-tech-baseline.md`, `docs/adr/ADR-0005-localization-en-ru.md`

## User story
As a user, I want to use the app in English or Russian with correctly formatted numbers/dates, so that balances and history are easy to read.

## Scope / Out of scope
Scope:
- `en` and `ru` locales.
- All user-visible strings sourced from generated `AppLocalizations`.
- In-app language override (System / English / Russian), persisted locally.
- Locale-aware formatting for:
  - money/asset amounts (decimal display),
  - dates (entry dates; “rates updated at” timestamps).

Out of scope:
- Additional locales beyond `en`/`ru`.
- Remote/persisted language preference synced across devices (local-only in MVP).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the device locale is English, when the user opens the app, then all user-visible strings are displayed in English.
- Given the device locale is Russian, when the user opens the app, then all user-visible strings are displayed in Russian.
- Given the user selects a language override in Profile, when the user navigates across screens or restarts the app, then the app uses the selected language instead of the system locale until the override is reset to System.
- Given any screen displays a numeric amount or converted total, when rendered, then the displayed number formatting matches the active locale (decimal separators, grouping).
- Given any screen displays a date (e.g., balance entry date, rates timestamp), when rendered, then it uses locale-aware formatting.
- Given a new user-visible string is introduced, when code is reviewed/CI runs, then missing translations in either `en` or `ru` are detected (via l10n generation/build failure or a check).

## UX references (which screens it touches; placeholders ok)
- All screens in MVP (cross-cutting).

## States (loading/empty/error/success)
- Loading/empty/error/success states must use localized strings (cross-cutting).

## Data needs (entities + fields)
- None (presentation concern).

## Analytics (events, optional)
- Optional: `locale_active { locale }` (logged once per app start for debugging; avoid sending to third parties in MVP per `docs/tech/integrations.md`).

## Open questions (if any)
- Should we expose a settings toggle to override system locale in MVP, or strictly follow OS locale? (Not specified in PRD/requirements.)
