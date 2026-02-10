# ADR-0003: Local JSON env via dart-define-from-file

**Status:** Accepted  
**Date:** 2026-02-10

## Context
We need dev/prod environment variables (e.g., Supabase URL + anon key) without committing secrets to the repo, while keeping local setup simple.

## Decision
- Store environment variables locally in:
  - `.config.dev.json`
  - `.config.prod.json`
- Add these files to gitignore.
- Use `flutter run --dart-define-from-file=...` (and IDE launch configs) to inject config into the app at build/run time.
- Commit example templates:
  - `.config.dev.json.example`
  - `.config.prod.json.example`

## Consequences
- Developers must create their local `.config.*.json` files from the examples.
- App code should read config via `const String.fromEnvironment(...)` (no runtime file IO).

