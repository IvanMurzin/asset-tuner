# Asset Tuner — PRD

**Last updated:** 2026-02-10  
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

### Asset
A currency/token held inside an account.
- MVP supports **known assets only** (no custom assets).
- Supported assets are provided by a backend catalog (fiat + crypto, full lists); client uses search/select.
- Two families:
  - **Fiat** (ISO currencies, e.g., USD, EUR, RUB).
  - **Crypto** (tokens/coins, e.g., BTC, ETH, USDT).

### Balance entry
Users update holdings over time using:
- **Snapshot**: “this is my current balance now”.
- **Adjustment (delta)**: “+X / −Y since last time”.

**Important behavioral decision:** when the user enters a snapshot, the system computes and stores an implied delta relative to the previous snapshot, so history always reflects “what changed”.
To keep history consistent across devices, snapshot updates are applied via a backend “update balance” operation that creates the implied delta.

## 6) Key user flows (MVP)
1. **Onboarding**
   - Sign in (Supabase OTP email; optional Google/Apple).
   - Choose base currency (default USD).
2. **Create account**
   - Choose account type (Bank / Crypto Wallet / Cash / Other).
   - Optional grouping hint (but MVP hierarchy is one level: Account → Assets).
3. **Add assets to account**
   - For bank/cash: typically fiat currencies.
   - For crypto wallet: multiple tokens.
4. **Enter balance**
   - Enter snapshot or delta with a date.
   - UI emphasizes a **monthly update** flow, while still allowing any-date entries.
   - App shows computed change (delta) and updates totals.
5. **View overview**
   - Global total in base currency.
   - Breakdown by account; drill-down to per-asset balances and history.
6. **Change base currency**
   - Global total recalculates using server-cached rates.
   - Missing-rate behavior: show **partial totals** (priced holdings) and mark the full total as **N/A** if not all holdings can be priced.

## 7) MVP feature list
### Must-have
- Auth (Supabase): email OTP + Google/Apple sign-in.
- Multi-device sync.
- Account CRUD (create/edit/archive/delete).
- Asset management inside account (add/remove asset, reorder optional).
- Balance entries (snapshot + delta), any date.
- Global total + breakdown; drill-down.
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
- Up to **20 tracked asset positions** (account-asset pairs)
- Base currency options: **USD, EUR, RUB**
- No free trial

### Paid tier (MVP)
- Higher limits (accounts + tracked asset positions)
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
- App shows a **partial converted total** (sum of priced holdings) and clearly indicates unpriced holdings.
- If not all holdings can be priced, the “full” converted total is **N/A** (original amounts still visible).

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
