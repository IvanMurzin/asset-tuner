# Review Rubric

Classify findings by impact and confidence.

## Severity Levels

## `blocker`

Use when change can break core behavior, data integrity, auth/security, or release readiness.

Examples:

- broken routing or crash on critical path
- security leak or secrets exposure
- destructive data regression

## `high`

Use when issue is likely user-visible and materially degrades feature behavior.

Examples:

- incorrect business logic on major flow
- missing required validation
- flaky behavior with high repro chance

## `medium`

Use when issue is non-blocking but worth fixing before commit if low-risk.

Examples:

- weak error handling
- maintainability risks in touched code
- missing tests for changed behavior

## Review Checklist

1. Correctness vs intended behavior.
2. Regression risk in neighboring logic.
3. Contract compatibility (docs/contracts, AGENTS rules).
4. Error and edge-case handling.
5. Test coverage for changed behavior.

## Fix Policy

1. Always fix `blocker`.
2. Fix `high` unless fix risk is disproportionate.
3. Fix `medium` when deterministic and local.
4. Record skipped findings with reason in `Remaining risks`.
