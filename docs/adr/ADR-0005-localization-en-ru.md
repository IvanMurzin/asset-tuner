# ADR-0005: Localization (en + ru) via gen-l10n

**Status:** Accepted  
**Date:** 2026-02-10

## Context
MVP requires English and Russian UI. We need a standard approach compatible with Flutter, easy to maintain, and friendly to codegen.

## Decision
- Use Flutter `gen-l10n` with ARB files.
- Locales: `en` and `ru`.
- Apply locale-aware number/date formatting across the app.

## Consequences
- UI strings must be sourced from generated `AppLocalizations`.
- New user-visible strings require translations in both locales.

