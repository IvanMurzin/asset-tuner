# Asset Tuner — Glossary

**Last updated:** 2026-02-12

- **Account**: A top-level container representing where value is stored (bank account, crypto wallet, cash). Can hold one or multiple assets.
- **Asset**: A currency/token held inside an account (fiat or crypto).
- **Subaccount (счёт)**: A user-created, named holding inside an account. It has:
  - a required user-defined `name` (not derived from currency),
  - an immutable currency/token (`asset`),
  - a balance history (snapshots).
- **Position**: Synonym for subaccount in MVP v2.
- **Base currency**: The currency the user chooses for conversion and global totals (e.g., USD, RUB).
- **Snapshot**: A balance entry representing the balance on a date (e.g., “BTC balance is 0.25 today”).
- **Diff**: The computed difference between the new snapshot and the previous snapshot for the same subaccount (server-computed for consistency).
- **Converted total**: Total value expressed in the base currency using stored rates.
- **Rate**: A stored price used for conversion (fiat FX rate or crypto USD price).
- **usdPrice**: USD value per 1 unit of an asset (used as a pivot for conversion to any base currency).
- **Rates timestamp**: When the system last updated rates from providers.
- **Fiat**: Government-issued currency (USD, EUR, RUB, etc.).
- **Crypto**: Blockchain-based token/coin (BTC, ETH, USDT, etc.).
- **RLS**: Row Level Security in Postgres/Supabase ensuring data isolation per user.
- **Freemium**: Free tier with limits + paid subscription to unlock more features/limits.
