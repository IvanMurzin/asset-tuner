# Asset Tuner — Vision

**Last updated:** 2026-02-10

## One-liner
Asset Tuner helps people with money in multiple currencies, countries, and crypto wallets **see their total wealth in a chosen base currency** and **track balance changes over time** with a simple manual workflow.

## Problem
Target users (digital nomads, expats, multi-currency earners, crypto holders) keep funds across:
- bank accounts in different countries,
- cash in multiple currencies,
- crypto wallets with multiple tokens.

As a result, they lack a fast and reliable answer to: **“How much money do I have right now (in one currency)?”** and it’s inconvenient to track changes over time.

## Product promise (MVP)
In under 30 seconds, a user can:
1) open the app,
2) see a global total in their base currency (e.g., USD or RUB),
3) understand what changed since last update,
4) drill down into each account/wallet and asset.

## Target users
- **Digital nomads / expats** with funds in multiple countries and currencies.
- **Crypto users** holding multiple tokens in multiple wallets.
- **Multi-currency savers** who want a clean, manual, low-friction overview (no bank connections required).

## What makes it different
- **Manual-first, zero bank integrations** (fast to ship, works globally).
- **Account → Assets hierarchy** supports multi-token wallets (e.g., TrustWallet → BTC/ETH/USDT) while still allowing simple “single-asset accounts” (e.g., Cash USD).
- **Always-converted view** via server-cached FX + crypto rates (hourly), so totals are consistent across devices.

## MVP scope (explicit)
- Assets only (no liabilities/debts).
- Manual balance tracking via snapshots and/or adjustments (deltas).
- Any-date entries (UI emphasizes a monthly update flow).
- Currency conversion to a user-selected base currency.
- Authentication + multi-device sync via Supabase.
- Freemium: free tier (5 accounts, 20 asset positions, base currencies USD/EUR/RUB) + paid upgrade (any base currency, higher limits, later analytics).

## Not in MVP (direction, not exhaustive)
- Expense tracking / categories / budgeting.
- Bank syncing / automatic imports.
- Securities/portfolio performance, tax lots, P&L.
- AI advice/insights.
- Advanced analytics and forecasting.

## Long-term direction
After a stable MVP and early monetization:
- richer analytics (allocation, trends, volatility, goal tracking),
- paid features (more accounts/assets/currencies, advanced analytics),
- optional AI insights,
- optional expense tracking module (separate from the asset overview).
