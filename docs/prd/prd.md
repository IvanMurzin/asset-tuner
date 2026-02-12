# Asset Tuner — PRD

**Last updated:** 2026-02-12  
**Platforms:** iOS + Android (Flutter)  
**Backend:** Supabase (Auth + Postgres + scheduled jobs)  
**Source of truth:** this `docs/prd/` folder

## 1) Summary
Asset Tuner is a manual, multi-currency asset tracking app that lets users model their real-world setup (banks, wallets, cash) and **see a single global total** in a chosen base currency, with balance change history over time.

## 2) Goals
### Product goals (MVP)
- Provide a fast, trustworthy **global total** in base currency.
- Make it easy to represent common structures:
  - multi-currency account (one account with multiple assets),
  - simple account (single asset).
- Support simple balance tracking over time without “full expense tracking”.
- Enable freemium monetization with clear value boundaries.

### Business goals (MVP)
- Validate willingness to pay for: higher limits, extra base currencies, analytics.
- Reach early retention benchmarks (see `success_metrics.md`).

## 3) Non-goals (MVP)
See `non_goals.md`.

## 4) Personas
See `personas.md`.

## 5) Core concepts (model)
### Account (top-level container)
Represents a real-world place where value is stored (bank account, crypto wallet, cash).
- Can be **single-asset** (e.g., “Cash USD”).
- Can be **multi-asset** (e.g., “TrustWallet” containing BTC/ETH/USDT).

### Subaccount (счёт) inside an account (MVP v2)
A subaccount is the concrete thing the user tracks and updates.
- Each subaccount has:
  - required user-defined name (e.g., “USDT (TRC20)”, “Bitcoin”),
  - an immutable currency/token (an `Asset` from catalog),
  - a balance history (snapshots).
- There can be **unlimited** subaccounts under an account, including multiple subaccounts with the same currency.

### Asset
A currency/token held inside an account.
- MVP supports **known assets only** (no custom assets).
- Supported assets are provided by a backend catalog (fiat + crypto, full lists); client uses search/select.
- Two families:
  - **Fiat** (ISO currencies, e.g., USD, EUR, RUB).
  - **Crypto** (tokens/coins, e.g., BTC, ETH, USDT).

### Balance entry
Users update holdings over time using:
- **Snapshot (MVP v2)**: “this is my balance today”.

**Important behavioral decision (MVP v2):** when the user enters a snapshot, the system computes and stores a **diff** relative to the previous snapshot, so history reflects “what changed”.
To keep history consistent across devices, snapshot updates are applied via a backend “update subaccount balance” operation that computes and stores the diff.

## 6) Key user flows (MVP)
1. **Onboarding**
   - Sign in (Supabase OTP email; optional Google/Apple).
   - Choose base currency (default USD).
2. **Create account**
   - Choose account type (Bank / Wallet / Exchange / Cash / Other).
3. **Add subaccounts (счета) to account (MVP v2)**
   - Choose currency/token from catalog, enter a user-defined name, enter initial balance (snapshot for today).
4. **Update balance (MVP v2)**
   - Enter a snapshot amount (date = today).
   - App shows computed diff and updates totals.
5. **View main screen**
   - Global total in base currency.
   - Breakdown by account; drill-down to per-subaccount balances and history.
6. **Change base currency**
   - Global total recalculates using server-cached rates.
   - Rates missing behavior: totals exclude positions that cannot be priced (MVP v2); analytics excludes them as well.

## 7) MVP feature list
### Must-have
- Auth (Supabase): email OTP + Google/Apple sign-in.
- Multi-device sync.
- Account CRUD (create/edit/archive/delete).
- Subaccounts inside account (create/rename/delete; unlimited; currency immutable).
- Snapshot-only balance entries (today) + history.
- Global total + breakdown; drill-down to account/subaccount.
- Currency conversion via server-cached rates (hourly refresh).
- Freemium limits + paywall UX.

### Nice-to-have (only if time permits)
- Simple import/export (CSV) of balances.
- Search/filter accounts.
- Basic “last updated” health indicator per account.

## 8) Monetization (freemium)
MVP includes free tier + paid upgrade.

### Free tier (MVP)
- Up to **5 accounts**
- Up to **20 subaccounts** (счета)
- Base currency options: **USD, EUR, RUB**
- No free trial

### Paid tier (MVP)
- Higher limits (accounts + subaccounts)
- Any base currency
- (Later) analytics features

## 9) Integrations & data (backend impact)
### Rates (Backend/API)
**Sources:**
- Fiat FX: OpenExchangeRates (free tier).
- Crypto USD prices: CoinGecko (API key via `COINGEKO_API_KEY`).

**Update strategy:**
- Supabase scheduled job runs **hourly** to fetch provider data and store rates in DB.
- Clients read rates from Supabase (no direct client calls to external APIs).

**Stored rate format (USD pivot):**
- Each asset has `usdPrice` (USD value per 1 unit of the asset).
- Conversion to any base currency is calculated client-side using USD as pivot.

**Missing rates:**
- MVP v2 excludes positions that cannot be priced from totals and analytics. The UI may show a small “some holdings excluded” banner, but does not list unpriced rows in analytics.

## 10) Constraints
- Flutter client follows repository architecture rules in `client/AGENTS.md` (layered architecture).
- Backend is Supabase-first; external APIs must be free/freemium.
- MVP timeline target: **2–4 weeks**.

## 11) Risks
- Provider rate limits / downtime → stale rates.
- FX correctness expectations (users may treat totals as “truth”) → must communicate “estimates” and timestamps.
- Decimal precision (crypto) → incorrect rounding if not handled carefully.
- Monetization misalignment (limits too strict/too generous).

## 12) Milestones (suggested)
- M0: Finalize PRD + MVP limits/pricing assumptions.
- M1: Auth + account/asset model + local UI skeleton.
- M2: Balance entries + overview + history.
- M3: Rates job + conversion + missing-rate states.
- M4: Paywall + analytics instrumentation + polish.
