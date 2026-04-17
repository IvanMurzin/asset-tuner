# Review Rubric

Review current diff before finalizing issue state.

## Severity

- `blocker`: data loss, crash, broken route/flow, contract break
- `high`: clear incorrect behavior, strong regression risk
- `medium`: maintainability/readability/test gap with moderate risk

## Review Checklist

1. Scope control: no unrelated changes.
2. Acceptance criteria: covered and testable.
3. Contracts/config: synchronized when affected.
4. Localization: `en` and `ru` updated when UI copy changed.
5. Navigation/state: no obvious regressions.
6. Tests/checks: relevant checks executed and reported.

## Action Rule

1. Fix all `blocker` and `high` findings.
2. Fix `medium` when low-risk and deterministic.
3. Keep unresolved items only with explicit rationale in final report.
