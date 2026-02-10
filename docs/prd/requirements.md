# Asset Tuner — Requirements

**Last updated:** 2026-02-10

Conventions:
- **FR** = Functional Requirement
- **NFR** = Non-Functional Requirement
- Tags:
  - **[Backend/Data]** affects database schema, RLS, or data model
  - **[Backend/API]** affects external providers, Edge Functions, cron/scheduled jobs

## Functional requirements (MVP)

### Authentication & accounts
- **FR-001**: User can sign in via Supabase email OTP. **[Backend/Data]**
- **FR-002**: User can sign in via Supabase Google and Apple OAuth. **[Backend/Data]**
- **FR-003**: User session persists across app restarts.
- **FR-004**: User data is isolated per user via RLS. **[Backend/Data]**

### Base currency & settings
- **FR-010**: User can select a **base currency** for converted totals (default: USD). **[Backend/Data]**
- **FR-011**: App shows when rates were last updated (timestamp).
- **FR-012**: Free tier base currency options are limited to **USD, EUR, RUB**; selecting any other base currency requires paid. **[Backend/Data]**

### Accounts (top-level containers)
- **FR-020**: User can create an account with a name and type (Bank / Crypto Wallet / Cash / Other). **[Backend/Data]**
- **FR-021**: User can edit account name/type.
- **FR-022**: User can archive an account (hidden from main totals but recoverable). **[Backend/Data]**
- **FR-023**: User can delete an account (with confirmation). **[Backend/Data]**

### Assets inside accounts
- **FR-030**: User can add supported assets (fiat currencies and crypto tokens) into an account. **[Backend/Data]**
- **FR-031**: Account may contain multiple assets (e.g., TrustWallet → BTC/ETH/USDT). **[Backend/Data]**
- **FR-032**: Account may be single-asset (e.g., Cash USD) without extra nesting. **[Backend/Data]**
- **FR-033**: MVP does **not** allow custom assets. (Supported list only.)
- **FR-034**: Supported fiat currencies and crypto tokens are provided by a backend catalog (full lists; not curated in client). **[Backend/Data]**

### Balance tracking (snapshots + deltas)
- **FR-040**: User can record a **snapshot** balance for an account asset at any date. **[Backend/Data]**
- **FR-041**: User can record a **delta adjustment** (+/−) for an account asset at any date. **[Backend/Data]**
- **FR-042**: When user enters a snapshot, the system computes an implied delta vs the previous snapshot and stores the change history. **[Backend/Data]**
- **FR-043**: App displays balance history per asset (at least as a list; charts optional).
- **FR-044**: App supports any-date entries; UI provides a monthly update flow as the default shortcut.
- **FR-045**: Snapshot updates are applied via a backend “update balance” operation that computes and stores the implied delta in a single operation. **[Backend/Data]**

### Conversion & totals
- **FR-050**: App displays a **global total** converted into the user’s base currency. **[Backend/Data]**
- **FR-051**: App displays per-account totals and per-asset amounts (original currency + converted where available).
- **FR-052**: If a required rate is missing, app shows a **partial converted total** (priced holdings only) and indicates unpriced holdings; the “full total” is **N/A**. **[Backend/Data]**

### Rates (server-cached)
- **FR-060**: System fetches fiat FX rates from OpenExchangeRates and stores them in DB. **[Backend/API]**
- **FR-061**: System fetches crypto USD prices from CoinGecko and stores them in DB. **[Backend/API]**
- **FR-062**: Rates update runs at least hourly via a Supabase scheduled job. **[Backend/API]**
- **FR-063**: Client reads rates only from Supabase (no direct provider calls in client). **[Backend/API]**
- **FR-064**: System stores `usdPrice` for each supported asset; client computes conversion to base currency using USD as pivot. **[Backend/Data]**

### Monetization (freemium)
- **FR-070**: App enforces free-tier limits: **5 accounts** and **20 tracked asset positions** (account-asset pairs). **[Backend/Data]**
- **FR-071**: App paywalls base currency selection beyond **USD, EUR, RUB**. **[Backend/Data]**
- **FR-072**: App paywalls analytics (post-MVP capability), with stubs/UX in MVP allowed.
- **FR-073**: Paid plan available as monthly + annual subscription. **[Backend/Data]**
- **FR-074**: App does not offer a free trial in MVP. **[Backend/Data]**

## Functional requirements (Post-MVP)
- **FR-200**: Liabilities/debts and true net worth.
- **FR-210**: Expense tracking (transactions, categories, budgets).
- **FR-220**: Advanced analytics (allocation, trends, charts, forecasting).
- **FR-230**: AI advice/insights.
- **FR-240**: Securities support.
- **FR-260**: “Hide amounts” privacy mode (blur totals until revealed).

## Non-functional requirements (MVP)
- **NFR-001**: App loads overview screen quickly on typical devices (no blocking on provider APIs; rates are read from DB).
- **NFR-002**: All user data access is protected by Supabase RLS. **[Backend/Data]**
- **NFR-003**: System handles decimal precision safely for crypto and fiat (no silent rounding that changes totals).
- **NFR-004**: Rate job is resilient to provider failures (retries/backoff; last-known rates preserved). **[Backend/API]**
- **NFR-005**: App clearly communicates when totals are estimates and shows rate timestamps.
- **NFR-006**: Client follows architecture constraints in `client/AGENTS.md` (layered architecture; presentation must not import data).
