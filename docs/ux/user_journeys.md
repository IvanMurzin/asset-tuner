# User Journeys

## First Launch
1. User opens the app; the splash screen restores the session.
2. A first-time user sees the onboarding carousel, which leads to Sign up (Sign in is one tap away).
3. After the first sign-in or sign-up, the first-auth paywall is shown once (skipped when the store
   is unavailable).
4. An authenticated user enters the guarded app flow. A new profile already has USD as its base
   asset.

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
3. User enters the current amount. The entry date is today and cannot be changed; there is no note
   field.
4. Backend writes an immutable balance entry.
5. Subaccount current amount, account total, overview, and analytics update after refresh.

## Change Base Asset
1. User opens Profile.
2. User opens Base currency.
3. User selects an unlocked asset and taps Save; the backend saves `profiles.base_asset_id`.
4. Overview and analytics use the new base asset after refresh.
5. If the selected asset is locked, the app opens the paywall; after a successful purchase the
   requested asset is applied without another Save.

## Upgrade
1. User hits a plan limit, taps a locked feature, or opens the paywall from Profile.
2. App presents the custom paywall built on RevenueCat offerings (RevenueCat UI is used only for the
   Customer Center in subscription management).
3. Successful purchase or restore syncs the subscription with the backend; the paywall closes once.
4. Backend profile plan changes to `pro`; previously locked actions become available.
5. A pending payment closes the paywall with an info message; Pro arrives when it settles.

## Contact Developer
1. User opens Profile.
2. User opens Contact Developer.
3. User submits a message.
4. Backend stores a support message and returns an accepted response.
