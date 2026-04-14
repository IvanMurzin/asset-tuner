# Agent Practices for Reliable Delivery

Use these practices as non-optional guardrails.

## Operating Model

1. Start with a single-agent path and simple plan.
2. Add complexity only when required by blockers.
3. Keep actions observable: list commands and artifacts.
4. Prefer deterministic steps over heuristic-only decisions.

## Tool Use Discipline

1. Use repo-local source of truth before assumptions.
2. Prefer precise commands over exploratory broad commands.
3. Minimize side effects while gathering context.
4. Never perform hidden state changes (staging/commit/push).

## Eval Loop (must run every task)

1. Define success criteria from issue Acceptance Criteria.
2. Implement smallest valid increment.
3. Run checks from `quality-gates.md`.
4. Compare actual output vs acceptance criteria.
5. If mismatch, iterate with focused fix and re-check.

## Reporting Standard

Final report must include:

1. `Changed`: concrete files and behavior.
2. `Auto checks`: commands + status.
3. `Manual checks`: step-by-step user validation.
4. `Risks`: unresolved items with impact.
