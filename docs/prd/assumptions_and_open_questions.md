# Asset Tuner — Assumptions & Open Questions

**Last updated:** 2026-02-12

## Assumptions (current plan)
1) **Manual-first MVP**: no bank syncing or automated imports.
2) **Assets-only MVP**: no liabilities/debts in v1.
3) **Known assets only**: supported fiat + crypto come from a backend catalog; no custom assets/tokens.
4) **One-level hierarchy**: Account → Subaccounts (счета). Each subaccount has an immutable asset (currency/token) from catalog and a user-defined name.
5) **Rates are server-cached**: hourly Supabase job fetches OpenExchangeRates + CoinGecko; clients read Supabase only.
6) **Missing rates**: app excludes holdings/updates that cannot be priced from totals and Analytics (MVP v2).
7) **Monetization**: subscription (monthly + annual), no free trial; free tier has clear limits and paywalls for extra base currencies and analytics.

## Decisions (finalized)
### Monetization
1) **Free-tier limits**
   - Accounts limit: **5**
   - Holdings limit: **20 subaccounts** (счета)
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
   - Totals and Analytics exclude holdings/updates that cannot be priced (MVP v2).
6) **Manual rate overrides**
   - **No** (not planned)

### Supported assets
7) **Fiat currencies**
   - **All** supported by the backend catalog
8) **Crypto tokens**
   - **All** supported by the backend catalog

### UX & behavior
9) **Default entry workflow (MVP v2)**
   - Snapshot-only, date defaults to **today**.
10) **Snapshot → diff (MVP v2)**
   - User enters current balance.
   - Client calls a backend “update subaccount balance” function; backend computes and stores the diff vs previous snapshot.

### Privacy & security
11) **App lock (PIN/biometric)**
   - No (not required in MVP)
12) **Hide amounts mode**
   - Later: yes (post-MVP)

## Remaining open questions
1) Pricing: exact monthly/annual price points (and regional pricing strategy).
2) “Analytics” scope for the paid plan: which concrete insights/charts are included in v1 vs later.
