# Agent Practices for Review+Refine

Use this as execution discipline for stable outcomes.

## Core Principles

1. Prefer explicit evidence over assumptions.
2. Keep fixes local to changed code unless dependency requires nearby update.
3. Favor reversible, low-risk edits first.
4. State uncertainty instead of masking it.

## Recommended Process

1. Read diff completely before first fix.
2. Build finding list by severity.
3. Fix highest-impact issues first.
4. Rerun checks after each meaningful fix batch.
5. Re-read diff to detect accidental regressions.

## Eval Loop

1. Define acceptance for each finding ("what means fixed").
2. Apply fix.
3. Validate with command or deterministic reasoning.
4. If not fixed, roll forward with a narrower follow-up fix.
5. Report final status (`fixed` / `remaining`).

## Communication Format

Use concise stable sections in final report:

1. `Found`
2. `Fixed`
3. `Remaining risks`
4. `Auto checks`
5. `Manual checks`
