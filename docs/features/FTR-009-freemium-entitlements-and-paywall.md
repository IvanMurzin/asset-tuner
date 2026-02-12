# FTR-009: Freemium limits, entitlements, and paywall UX (MVP v2)

## Summary
Enforce free-tier limits (5 accounts, 20 subaccounts, base currency limited to USD/EUR/RUB) and provide a paid subscription upgrade (monthly/annual) that unlocks higher limits and any base currency.

Source references:
- Product: `docs/prd/prd.md` (free vs paid), `docs/prd/requirements.md` (FR-070..FR-074)
- Tech: `docs/tech/integrations.md` (payments integration TBD), `docs/tech/api_assumptions.md` (`profiles` entitlements), `docs/tech/dependencies.md` (payments ADR required)

## User story
As a user, I want a clear free tier with upgrade options, so that I can try the app quickly and pay when I hit meaningful limits.

## Scope / Out of scope
Scope:
- Free-tier enforcement:
  - Max accounts: 5
  - Max subaccounts: 20 (счета)
  - Base currency choices limited to USD/EUR/RUB (integration point with FTR-003)
- Paywall UX:
  - Shown when user attempts an action that exceeds free limits (creating 6th account, adding 21st subaccount, selecting non-free base currency).
  - Explains what is locked and what paid unlocks.
- Subscription purchase flow:
  - Monthly + annual plans.
  - Entitlement state stored in backend `profiles` (or an entitlements table) and reflected in client gating.

Out of scope:
- Free trial (explicitly not in MVP; see `docs/prd/requirements.md` FR-074).
- Paid analytics features (post-MVP capability; see `docs/prd/requirements.md` FR-072, FR-220).
- Regional pricing strategy (open question; see `docs/prd/assumptions_and_open_questions.md`).

## Acceptance Criteria (BDD-style, unambiguous)
- Given the user is on the free tier, when they attempt to create an account that would exceed 5 total accounts, then the app:
  - blocks the creation,
  - shows the paywall with messaging specific to the “accounts limit”.
- Given the user is on the free tier, when they attempt to create a subaccount that would exceed 20 total subaccounts, then the app:
  - blocks the add,
  - shows the paywall with messaging specific to the “subaccounts limit”.
- Given the user is on the free tier, when they attempt to select a base currency outside USD/EUR/RUB, then the app shows the paywall and does not change `profiles.base_currency` (see FTR-003).
- Given the user purchases a subscription successfully, when entitlements are refreshed, then:
  - the user is able to exceed free-tier limits according to the paid plan,
  - base currency selection allows any supported base currency.
- Given the app cannot verify entitlements (network error), when gating is evaluated, then:
  - the app treats the user as free tier for safety,
  - shows a non-blocking message “Couldn’t verify subscription; try again” if the user is currently blocked by a paywall.
- Given the subscription is cancelled/expired, when entitlements are refreshed, then:
  - the user returns to free-tier gating for new actions,
  - existing data remains visible (no data deletion), but new actions beyond limits are blocked.

## UX references (which screens it touches; placeholders ok)
- Screen: Paywall (modal or full-screen)
- Screen: Settings → Manage subscription (optional link-out)
- Entry points:
  - Create account (FTR-004)
  - Add subaccount to account (FTR-005)
  - Base currency settings (FTR-003)

## States (loading/empty/error/success)
- Loading: loading entitlement state; purchase flow in progress.
- Empty: n/a.
- Error:
  - purchase_failed (provider error)
  - network (entitlements refresh failed)
  - unknown
- Success: entitlement active; gated actions unlock.

## Data needs (entities + fields)
- `profiles` (user-owned)
  - `plan: text` in {free, paid}
  - `entitlements: jsonb` (or structured fields), including:
    - `max_accounts: int`
    - `max_subaccounts: int`
    - `any_base_currency: bool`
    - `expires_at: timestamptz?`
  - `updated_at: timestamptz`
- Optional separate table:
  - `subscriptions { user_id, provider, status, expires_at, raw_receipt_ref }` (if needed)

## Analytics (events, optional)
Local logging only in MVP (no third-party per `docs/tech/integrations.md`):
- `paywall_viewed { reason }`
- `purchase_started { plan }`
- `purchase_succeeded { plan }`
- `purchase_failed { plan, failure_code }`

## Open questions (if any)
- Payments provider choice is explicitly TBD and requires an ADR (`docs/tech/dependencies.md`). Which provider do we target for MVP (e.g., `in_app_purchase` with App Store / Play Billing)?
- Paid plan exact limits (beyond “higher limits”) are not specified. Define concrete paid caps (or “unlimited”) for MVP gating logic.

**MVP decision (client-only mock):** treat `plan=paid` as effectively unlimited for gating:
- `max_accounts = 999`
- `max_subaccounts = 9999`
- `any_base_currency = true`
