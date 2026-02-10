# ADR-0004: Use Decimal for money and rates

**Status:** Accepted  
**Date:** 2026-02-10

## Context
The app computes totals across fiat and crypto with varying decimal precision. Using `double` risks rounding drift and user-visible inconsistencies.

## Decision
- Use `decimal` for all money/rate arithmetic in Flutter.
- Store values in Postgres as `numeric` (not float).
- Convert between DB and client using string representations (avoid parsing through `double`).

## Consequences
- DTOs should carry numeric fields as strings in JSON where appropriate (or explicitly document numeric parsing rules).
- Formatting for display uses locale-aware formatting; calculation always uses Decimal.

