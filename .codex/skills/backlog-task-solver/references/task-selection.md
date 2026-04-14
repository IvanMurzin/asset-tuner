# Task Selection Algorithm

Use this algorithm exactly when issue ID is not explicitly provided.

## Inputs

- Backlog index: `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- Issue docs: `docs/backlog/2026-03-product-quality-audit/issues/*.md`

## Deterministic Order

Section order (fixed):

1. `CONF`
2. `AUTH`
3. `DS`
4. `CUR`
5. `SUB`
6. `PRO`
7. `ANA`
8. `SUP`

Priority order inside each section:

1. `P0`
2. `P1`
3. `P2`

Tie-breaker inside same section+priority:

1. appearance order in `INDEX.md`

Candidate eligibility:

1. issue file exists
2. issue `Статус` in metadata is not `Done`

## Steps

1. Parse section list in order from `INDEX.md`.
2. For each section:
   1. group lines by `P0`, then `P1`, then `P2`
   2. walk each group top-to-bottom
   3. open issue file and read `Статус`
   4. pick first with status not equal to `Done`
3. Return selected issue ID + file path.
4. If none found, return "No available tasks".

## Status Source of Truth

Primary status source is issue file metadata line:

- `- Статус: \`...\``

Do not use `INDEX.md` marker as single source of truth; treat it as projection and keep it in sync after implementation.
