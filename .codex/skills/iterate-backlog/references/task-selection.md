# Task Selection Algorithm

Use this algorithm when issue ID is not explicitly provided.

## Inputs

- `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- `docs/backlog/2026-03-product-quality-audit/issues/*.md`

## Deterministic Order

Section order:

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

Tie-breaker:

1. appearance order in `INDEX.md`

Eligibility:

1. issue file exists,
2. issue status is neither `Done` nor `Blocked`.

## Status Source of Truth

Primary status source is issue file metadata line:

- `- Статус: \`...\``

`INDEX.md` is projection and must be synchronized after each run.
