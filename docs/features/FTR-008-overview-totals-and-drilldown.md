# FTR-008: Overview totals, breakdown, drill-down (with missing-rate behavior)

## Summary
Provide an Overview showing global total in base currency, per-account totals, and per-asset amounts, with drill-down to asset history; handle missing rates via partial totals and “N/A” full totals when not all holdings can be priced.

Source references:
- Product: `docs/prd/prd.md` (overview + drill-down; missing rates), `docs/prd/requirements.md` (FR-050..FR-052, FR-011)
- Tech: `docs/tech/stack.md` (online-first + graceful offline view-only), `docs/tech/api_assumptions.md` (reads; pagination)
- ADRs: `docs/adr/ADR-0004-decimal-precision.md` (Decimal arithmetic)

## User story
As a user, I want to immediately see how much money I have in my base currency and what changed, and drill down to understand which accounts/assets drive changes.

## Scope / Out of scope
Scope:
- Overview screen:
  - Global total in base currency.
  - Per-account totals.
  - Indicators for missing rates and last rates update timestamp.
- Account drill-down:
  - List of asset positions with original amounts and converted amounts (if priced).
- Asset position drill-down:
  - Balance history list (from FTR-006).
- Missing-rate behavior:
  - Show partial converted total (sum of priced holdings).
  - If any holding is unpriced, show full total as `N/A` and list unpriced holdings.
- Decimal-safe arithmetic in client (no `double` for totals; see `docs/adr/ADR-0004-decimal-precision.md`).
- Online-first with graceful offline read-only:
  - Show last-known cached overview snapshot if available.
  - Block mutations while offline.

Out of scope:
- Advanced analytics charts/allocations/forecasting (explicitly post-MVP; see `docs/prd/non_goals.md`).
- Liabilities/debts (post-MVP; see `docs/prd/requirements.md` FR-200).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user has at least one asset position with at least one balance entry, when the user opens the Overview screen, then the app displays:
  - base currency code,
  - global converted total (or `N/A` per missing-rate rules),
  - per-account totals,
  - rates “last updated” timestamp (or a missing state if not available).
- Given all holdings have available rates, when totals are computed, then:
  - the global total equals the sum of all asset positions converted to base currency using USD pivot `usdPrice`,
  - per-account totals sum to the same global total.
- Given at least one holding lacks a required rate, when totals are computed, then:
  - the app displays a partial converted total including only priced holdings,
  - the full converted total is shown as `N/A`,
  - unpriced holdings are listed with original amounts and asset codes.
- Given the user taps an account, when the Account detail opens, then each asset position shows:
  - latest known original amount (from balance entries),
  - converted amount if priced, otherwise an “Unpriced” indicator.
- Given the user is offline, when they open the Overview screen, then:
  - if a cached overview snapshot exists, it is displayed with an “Offline / Last updated” indicator,
  - if no cached snapshot exists, an offline empty/error state is shown with a “Try again” action when back online.
- Given the app performs arithmetic for totals, when computed, then it uses Decimal math (no floating-point drift) and rounds for display only (calculation preserves precision).

## UX references (which screens it touches; placeholders ok)
- Screen: Overview
- Screen: Account detail (drill-down)
- Screen: Asset position detail (history; from FTR-006)
- UI: Pull-to-refresh on Overview (per `docs/tech/api_assumptions.md` realtime is off; refresh on resume + manual refresh)

## States (loading/empty/error/success)
- Loading: fetching accounts/assets/balances/rates; computing totals.
- Empty:
  - No accounts → CTA “Create account” (links to FTR-004).
  - Accounts exist but no assets → CTA “Add asset” (links to FTR-005).
  - Assets exist but no balances → CTA “Add balance” (links to FTR-006).
- Error:
  - network/offline (show cached snapshot if available)
  - unauthorized (force sign-in)
  - unknown (retry)
- Success: totals visible, drill-down works.

## Data needs (entities + fields)
Reads (RLS-protected):
- `accounts { id, name, type, archived }`
- `account_assets { id, account_id, asset_id }`
- `balance_entries` (to derive latest balance per account_asset)
  - For “latest balance”, define deterministic rule (e.g., newest by `entry_date desc, created_at desc` per `docs/tech/api_assumptions.md`).
Public reads:
- `assets { id, kind, code/symbol, name }`
- `asset_rates_usd { asset_id, usd_price, as_of }`
Local cache (client):
- `overview_cache { computed_at, base_currency, totals_snapshot_json }` (implementation detail; may use `shared_preferences` per `docs/tech/dependencies.md`)

## Analytics (events, optional)
- `overview_viewed { has_unpriced_holdings }`
- `overview_refresh { result }`
- `drilldown_account_opened { account_id }`

## Open questions (if any)
- “Current balance” derivation:
  - **MVP decision:** compute current balance by applying entries in chronological order (`entry_date asc, created_at asc`):
    - Snapshot sets the balance to `snapshot_amount`.
    - Delta adds `delta_amount`.
  - History display remains sorted by `entry_date desc, created_at desc`.
