# Product Overview

Asset Tuner helps a user track assets across accounts, currencies, and crypto holdings in one base-currency view.

## Current Product
- Mobile app built with Flutter.
- Backend built on Supabase Auth, Postgres, SQL RPC functions, and Edge Functions.
- Users sign in with email/password and optionally configured OAuth providers.
- Each user has a profile with a plan and a base asset.
- Users create top-level accounts such as bank, wallet, exchange, cash, or other.
- Accounts contain subaccounts. A subaccount is a named holding tied to one immutable asset.
- Assets are backend-provided fiat and crypto catalog entries.
- Balances are snapshot-based. Setting a subaccount balance writes a new immutable balance entry and updates the current balance.
- Overview shows current totals in the user base asset, account totals, rates freshness, and drilldown into accounts and subaccounts.
- Analytics shows current asset breakdown and recent balance update feed.
- Free users are limited by backend plan limits; pro users unlock higher limits and broader asset/base-asset choices.
- RevenueCat manages subscription state. The backend stores the resulting plan.
- The app supports English and Russian UI localization.

## Product Promise
Give users a practical, low-friction way to answer:

- How much do I have in total?
- Where is it stored?
- Which assets or currencies make up the total?
- What changed recently?

## Non-Goals
- Expense categorization.
- Budgeting.
- Brokerage execution or trading.
- Manual custom assets.
- User-managed exchange rates.
- Multi-user shared accounts.
- Full offline mutation support.

## Source Of Truth Policy
This document describes the current product. Proposed changes belong in active specs under `docs/specs/active/`.
