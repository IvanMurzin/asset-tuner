# Navigation model (MVP v2)

## Auth gating
- App starts at `SCR-001` (session restore).
- If unauthenticated → `SCR-002` (Sign-in).
- After sign-in (and optional onboarding `SCR-003`) the user enters the authenticated shell.

## Authenticated shell (bottom tabs)
The app uses a bottom tab bar with exactly 3 tabs:
1) **Main** → `SCR-004`
2) **Analytics** → `SCR-017`
3) **Profile** → `SCR-009`

Rules:
- The bottom tab bar is visible on all three tab roots.
- Deeper screens are pushed above the shell (no bottom bar):
  - `SCR-006` (Account form)
  - `SCR-007` (Account detail)
  - `SCR-008` (Create subaccount)
  - `SCR-010` (Subaccount detail)
  - `SCR-011` (Update balance)
  - `SCR-012` (Base currency settings)
  - `SCR-013` (Paywall)
  - `SCR-014` (Manage subscription)
- Back behavior:
  - From deeper screens, back returns to the previous screen within the same tab flow.
  - Switching tabs preserves each tab’s navigation stack (recommended), but MVP may reset to tab root if needed.

## Top bars
- `SCR-004` Main: no Settings icon in app bar; Profile is reachable via the Profile tab.
