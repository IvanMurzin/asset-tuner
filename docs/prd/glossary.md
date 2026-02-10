# Asset Tuner — Glossary

**Last updated:** 2026-02-10

- **Account**: A top-level container representing where value is stored (bank account, crypto wallet, cash). Can hold one or multiple assets.
- **Asset**: A currency/token held inside an account (fiat or crypto).
- **Asset position**: An asset held in a specific account (account + asset pair). Used for free-tier limits.
- **Base currency**: The currency the user chooses for conversion and global totals (e.g., USD, RUB).
- **Snapshot**: A balance entry representing the current balance at a specific time (e.g., “BTC balance is 0.25”).
- **Delta / Adjustment**: A balance entry representing a change (+/−) since the previous state.
- **Implied delta**: The computed difference created when a user enters a snapshot (new snapshot minus previous snapshot).
- **Converted total**: Total value expressed in the base currency using stored rates.
- **Partial converted total**: Converted total that includes only holdings with available rates; unpriced holdings are excluded and shown separately.
- **Rate**: A stored price used for conversion (fiat FX rate or crypto USD price).
- **usdPrice**: USD value per 1 unit of an asset (used as a pivot for conversion to any base currency).
- **Rates timestamp**: When the system last updated rates from providers.
- **Fiat**: Government-issued currency (USD, EUR, RUB, etc.).
- **Crypto**: Blockchain-based token/coin (BTC, ETH, USDT, etc.).
- **RLS**: Row Level Security in Postgres/Supabase ensuring data isolation per user.
- **Freemium**: Free tier with limits + paid subscription to unlock more features/limits.
