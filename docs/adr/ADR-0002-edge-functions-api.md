# ADR-0002: Prefer Supabase Edge Functions for writes

**Status:** Accepted  
**Date:** 2026-02-10

## Context
The MVP includes workflows that must be consistent across devices and safe under concurrent updates (notably: snapshot entry that computes and stores implied deltas). It also includes destructive actions (account deletion) that should be validated and executed server-side in a single trusted place.

Supabase offers:
- PostgREST (table CRUD under RLS)
- Postgres functions (RPC)
- Edge Functions (Deno, HTTP)

## Decision
- Use PostgREST direct reads for simple queries under RLS.
- Prefer **Edge Functions** for:
  - write workflows (snapshot/delta) requiring server-side validation and consistent history,
  - cascade deletes (account deletion),
  - scheduled jobs (rates sync),
  - any operation that would otherwise require `security definer` SQL.

## Consequences
- We define and maintain an explicit API contract for Edge Functions (request/response + error codes).
- Client data layer implements:
  - request correlation id (optional),
  - normalized error mapping to `Failure { code, message }`,
  - logging of important API events (success/failure with safe metadata).

