# FTR-003: Base currency settings (free vs paid)

## Summary
Let users choose a base currency for converted totals, with free-tier limited to USD/EUR/RUB and paid tier allowing any supported fiat currency.

Source references:
- Product: `docs/prd/prd.md` (base currency flow + missing-rate behavior), `docs/prd/requirements.md` (FR-010..FR-012, FR-071)
- Tech: `docs/tech/api_assumptions.md` (`profiles`), `docs/tech/integrations.md` (payments TBD)

## User story
As a user, I want to choose a base currency so that the global total matches the currency I think in.

## Scope / Out of scope
Scope:
- Base currency stored per user in `profiles.base_currency`.
- Default base currency: USD.
- Base currency picker uses supported fiat assets from backend catalog (no hardcoded list in client besides free-tier gating).
- Free tier can select only: USD, EUR, RUB.
- Selecting any other base currency triggers paywall (see FTR-009) and does not change `profiles.base_currency` unless entitlement is active.

Out of scope:
- Custom base currencies.
- Manual rate overrides (explicit non-goal; see `docs/prd/non_goals.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given a new user with no base currency set, when their profile is created, then `profiles.base_currency` defaults to `USD`.
- Given the user is on the free tier, when they open base currency settings, then they can select `USD`, `EUR`, or `RUB` and save successfully.
- Given the user is on the free tier, when they attempt to select a base currency other than `USD|EUR|RUB`, then:
  - the app shows the paywall (FTR-009),
  - the base currency remains unchanged in `profiles`.
- Given the user has paid entitlement for “any base currency”, when they select any supported fiat currency and save, then `profiles.base_currency` is updated and the Main totals are recalculated using the new base currency.
- Given the app fails to load the fiat catalog, when the user opens base currency settings, then the screen shows a retryable error state (mapped `Failure` codes per `docs/tech/api_assumptions.md`).

## UX references (which screens it touches; placeholders ok)
- Screen: Onboarding base currency step (optional; see FTR-001 open question)
- Screen: Settings → Base currency
- Screen: Paywall (FTR-009)

## States (loading/empty/error/success)
- Loading: fetching fiat assets list; saving selection.
- Empty: no fiat assets returned (should be treated as error; catalog is expected to be non-empty).
- Error: network/unknown; forbidden if backend denies catalog read (should not happen if public read policies exist).
- Success: base currency saved; overview recalculated.

## Data needs (entities + fields)
- `profiles.base_currency: text`
- Read-only catalog `assets` filtered to fiat:
  - `asset_id: uuid` (or equivalent)
  - `code: text` (ISO currency code; may be `symbol`)
  - `name: text`
  - `kind: "fiat"`
- Entitlements/plan fields finalized by FTR-009.

## Analytics (events, optional)
- `base_currency_opened {}`
- `base_currency_changed { from, to, tier }`
- `base_currency_paywall_shown { attempted_currency }`

## Open questions (if any)
- Should the “any base currency” entitlement allow selecting crypto as base currency? (PRD implies base currency is a currency; free-tier list is fiat. Clarify scope.)

## Implementation checklist (AC → where it’s satisfied)
- Default base currency is USD on profile creation:
  - `client/lib/data/profile/repository/profile_repository.dart` (`ensureProfile` creates/normalizes `baseCurrency: 'USD'`)
  - `client/lib/presentation/auth/bloc/splash_cubit.dart` (bootstraps profile before routing)
- Free tier can save only USD/EUR/RUB in Settings → Base currency:
  - `client/lib/presentation/settings/bloc/base_currency_settings_cubit.dart` (`freeAllowedCodes`, gating in `selectCurrency`/`save`)
  - `client/lib/presentation/settings/page/base_currency_settings_page.dart` (picker + Save CTA)
  - Tests: `client/test/base_currency_settings_cubit_test.dart`
- Free tier selecting any other currency shows paywall and does not update profile:
  - `client/lib/presentation/settings/bloc/base_currency_settings_cubit.dart` (routes to paywall instead of persisting)
  - `client/lib/presentation/paywall/page/paywall_page.dart` + `client/lib/presentation/paywall/bloc/paywall_cubit.dart` (upgrade stub; returns `true` on upgrade)
  - Tests: `client/test/base_currency_settings_cubit_test.dart`
- Paid entitlement allows selecting any supported fiat currency and saving:
  - `client/lib/presentation/paywall/bloc/paywall_cubit.dart` (`upgrade` updates `profiles.plan` → `paid`)
  - `client/lib/presentation/settings/page/base_currency_settings_page.dart` (reload after paywall; retries selection)
  - Tests: `client/test/base_currency_settings_cubit_test.dart`
- Catalog load failures show retryable error state:
  - `client/lib/presentation/settings/page/base_currency_settings_page.dart` (`DSInlineError` with retry)
  - `client/lib/presentation/settings/bloc/base_currency_settings_cubit.dart` (maps failures to `loadFailureCode`)
- Empty fiat catalog is treated as an error:
  - `client/lib/presentation/settings/bloc/base_currency_settings_cubit.dart` (empty list → `error`)
  - `client/lib/presentation/onboarding/bloc/base_currency_cubit.dart` (empty list → `error`)
- Main reflects base currency changes after saving:
  - `client/lib/presentation/overview/bloc/overview_cubit.dart` + `client/lib/presentation/overview/page/overview_page.dart` (base currency chip reloads after returning)
