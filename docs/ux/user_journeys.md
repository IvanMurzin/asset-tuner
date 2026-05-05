# User Journeys

## First Launch
1. User opens the app.
2. App restores session.
3. Unauthenticated user lands on Sign in.
4. Authenticated user enters the guarded app flow.
5. Profile is ensured before product data loads.

## Create First Portfolio Structure
1. User opens Overview.
2. Empty state prompts account creation.
3. User creates an account.
4. User opens account detail.
5. User creates a subaccount by choosing a backend catalog asset and initial amount.
6. Overview reflects the new holding after refresh.

## Set A Balance
1. User opens a subaccount detail screen.
2. User opens Set balance.
3. User enters the current amount and optional note.
4. Backend writes an immutable balance entry.
5. Subaccount current amount, account total, overview, and analytics update after refresh.

## Change Base Asset
1. User opens Profile.
2. User opens Base currency.
3. User selects an unlocked asset.
4. Backend saves `profiles.base_asset_id`.
5. Overview and analytics use the new base asset after refresh.
6. If the selected asset is locked, the app routes to the paywall.

## Upgrade
1. User hits a plan limit or opens subscription management.
2. App presents RevenueCat paywall UI.
3. Successful purchase refreshes backend entitlements.
4. Backend profile plan changes to `pro`.
5. Previously locked actions become available.

## Contact Developer
1. User opens Profile.
2. User opens Contact Developer.
3. User submits a message.
4. Backend stores a support message and returns an accepted response.
