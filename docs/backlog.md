# Backlog

Lightweight running list of known issues and improvements that are **not release-blocking**.
Promote an item to a full spec (`docs/specs/active/`) when it is scheduled for implementation.

| ID | Type | Area | Summary | Notes |
|----|------|------|---------|-------|
| BL-0001 | bug/feature | paywall / base currency | After a base-currency-triggered purchase, the requested currency is not auto-applied | Details below |
| BL-0002 | improvement | billing / backend | Webhook and refresh grant Pro from Test Store / sandbox events | Details below |

---

## BL-0001 — Auto-apply requested base currency after paywall purchase

**Type:** bug / unfinished feature — **Priority:** low (not release-blocking)

**What happens:** When a free user picks a Pro-only base currency (e.g. CAD),
`_openBaseCurrencyPaywall` navigates to the paywall with
`PaywallArgs(reason: baseCurrency, requestedBaseCurrencyCode: code)`
(`client/lib/presentation/settings/page/base_currency_settings_page.dart`). After a
successful purchase the paywall just closes; the user lands back without the
currency applied and has to re-select it manually.

**Root cause:** `PaywallArgs.requestedBaseCurrencyCode` is only ever written, never
read. Grep confirms no consumer. The purchase-completion path
(`_onPurchaseOrRestoreCompleted` in `paywall_page.dart`) does not apply it.

**Proposed fix:** On confirmed Pro in `_onPurchaseOrRestoreCompleted`, if
`reason == baseCurrency` and `requestedBaseCurrencyCode != null`, apply it via
`ProfileCubit.updateBaseCurrency(code)` before dismissing the paywall (server now
allows it because the profile is Pro). ~10 lines.

**Observed:** testrc1@gmail.com, 2026-07-15 — paid annual to unlock CAD, was returned
still on USD, set CAD manually afterwards.

---

## BL-0002 — Do not grant Pro from Test Store events in the shared database

**Type:** improvement — **Priority:** low (not release-blocking after SPEC-0008)

**What happens:** `revenuecat_webhook` and `revenuecat/refresh` ignore `event.environment` and
`store`, so a Test Store or sandbox purchase sets `profiles.plan = pro` in the shared dev = prod
database (QA-004).

**Mitigation in place:** SPEC-0008 keeps the Test Store key out of prod builds; Google Play
sandbox is limited to license testers.

**Proposed fix:** record `environment`/`store` in the ledger and ignore `TEST_STORE` grants unless
the app user id is in a QA allowlist. Superseded if dev and prod projects are split.
