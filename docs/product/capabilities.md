# Product Capabilities

## Authentication And Profile
- Supabase Auth owns sessions.
- The app restores a persisted session on launch.
- Auth-driven redirects are centralized in `client/lib/core/routing`.
- A profile row is ensured for authenticated users.
- Profile fields include `plan`, `base_asset_id`, and optional `revenuecat_app_user_id`.

## Assets And Base Asset
- Assets are backend catalog entries with `kind`, `code`, `name`, `provider`, `provider_ref`, `rank`, and `decimals`.
- The catalog contains fiat and crypto assets.
- The backend returns `is_locked` for catalog rows according to the user plan.
- Base asset is stored as `profiles.base_asset_id`.
- Free users are limited by plan limits. Pro users can access broader catalog choices.

## Accounts
- Accounts are user-owned top-level containers.
- Account fields include `name`, `type`, `archived`, cached USD total, and timestamps.
- Users can create, update, archive, unarchive, and delete accounts.
- Deleting an account cascades dependent user data through backend RPC logic.

## Subaccounts
- Subaccounts belong to an account and are tied to one immutable asset.
- Subaccount fields include `name`, `asset_id`, `archived`, `current_amount_atomic`, and `current_amount_decimals`.
- Users can create, rename/archive, and delete subaccounts.
- A subaccount asset cannot be changed after creation.

## Balance Entries
- Balance entries are immutable snapshots.
- Setting a balance writes `amount_atomic`, `amount_decimals`, optional `note`, and `created_at`.
- The backend rejects unchanged balance submissions.
- History is read through `api/subaccounts/history` with cursor pagination.

## Overview
- Overview loads profile, accounts, subaccounts, assets, and rates through app data sources.
- Totals use decimal-safe atomic amount values.
- The app displays original asset amounts and converted values when rates are available.
- Archived accounts are separated from the default active account view.

## Analytics
- Analytics is served by `api/analytics/summary`.
- It returns the base asset, rates timestamp, asset breakdown, and recent balance updates.
- Values are expressed with atomic amount fields and decimals.

## Monetization
- Plans are `free` and `pro`.
- Backend plan limits define account, subaccount, fiat, and crypto access caps.
- RevenueCat SDK handles client purchase UI.
- RevenueCat refresh and webhook flows update backend plan state.

## Support
- The Contact Developer flow writes support messages through `api/contact_developer`.
- The backend stores messages in `support_messages`; it does not send email directly.
