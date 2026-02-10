# Asset Tuner — Assumptions & Open Questions

**Last updated:** 2026-02-10

## Assumptions (current plan)
1) **Manual-first MVP**: no bank syncing or automated imports.
2) **Assets-only MVP**: no liabilities/debts in v1.
3) **Known assets only**: supported fiat + crypto come from a backend catalog; no custom assets/tokens.
4) **One-level hierarchy**: Account → Assets; “single-asset accounts” are modeled as accounts with exactly one asset.
5) **Rates are server-cached**: hourly Supabase job fetches OpenExchangeRates + CoinGecko; clients read Supabase only.
6) **Missing rates**: app shows a **partial converted total** (priced holdings only) and clearly marks unpriced holdings; full converted total may be **N/A**.
7) **Monetization**: subscription (monthly + annual), no free trial; free tier has clear limits and paywalls for extra base currencies and analytics.

## Decisions (finalized)
### Monetization
1) **Free-tier limits**
   - Accounts limit: **5**
   - Assets/currencies limit: **20 tracked asset positions** (account-asset pairs)
2) **Base currencies**
   - Free: **USD, EUR, RUB**
   - Paid: **any other base currency**
3) **Free trial**
   - **No**

### Rates & conversion
4) **Stored rate format (USD pivot)**
   - Each asset has `usdPrice` (USD value per 1 unit of the asset).
   - Conversion to any base currency is calculated client-side using USD as pivot.
5) **Missing rates behavior**
   - Show **partial totals** (sum of priced holdings) and indicate unpriced holdings.
   - If not all holdings can be priced, the “full total” is shown as **N/A**.
6) **Manual rate overrides**
   - **No** (not planned)

### Supported assets
7) **Fiat currencies**
   - **All** supported by the backend catalog
8) **Crypto tokens**
   - **All** supported by the backend catalog

### UX & behavior
9) **Default entry workflow**
   - Yes: emphasize a **monthly update** flow (while still allowing any-date entries).
10) **Snapshot → implied delta**
   - User enters current balance.
   - Client calls a backend “update balance” function; backend computes and stores the implied delta.

### Privacy & security
11) **App lock (PIN/biometric)**
   - No (not required in MVP)
12) **Hide amounts mode**
   - Later: yes (post-MVP)

## Remaining open questions
1) Pricing: exact monthly/annual price points (and regional pricing strategy).
2) “Analytics” scope for the paid plan: which concrete insights/charts are included in v1 vs later.
