---
name: resolve-spec
description: Resolve one Asset Tuner spec end-to-end by ID: read source-of-truth docs and code, implement strictly to the spec, verify, update docs if needed, move the spec to docs/specs/resolved, update docs/specs/INDEX.md, and commit as spec(SPEC-####): summary.
---

# Resolve Spec

Use this skill when the user asks to implement or resolve a spec such as `SPEC-0001`.

## Source Of Truth
Read before editing:
- selected spec file from `docs/specs/active/` or `docs/specs/resolved/`
- `docs/README.md`
- `docs/specs/README.md`
- relevant product docs in `docs/product/`
- relevant technical/contracts docs in `docs/tech/` or `docs/contracts/`
- current code related to the spec

## Workflow
1. Locate the spec ID in `docs/specs/INDEX.md`.
2. Read the spec and confirm it is `Ready`. If it is not `Ready`, stop and explain what is missing.
3. Stop if the spec is ambiguous, conflicts with architecture, requires unavailable secrets/accounts, or would require unrelated refactors.
4. Set the spec status to `In Progress` and update `docs/specs/INDEX.md`.
5. Implement only the spec scope.
6. Run verification commands named in the spec, plus required local checks for changed areas.
7. Update docs when behavior, architecture, API, UX, operations, or workflow changed.
8. Set the spec status to `Resolved`, set the resolved date, move it to `docs/specs/resolved/`, and update `docs/specs/INDEX.md`.
9. Commit all related changes with `spec(SPEC-####): short-summary`.

## Hard Rules
- Never mark a spec resolved if acceptance criteria are not satisfied.
- Never hide failing checks.
- Never manually edit generated files.
- Do not change scope without updating the spec first.
- Do not push unless the user explicitly asks.

## Output
Report:
- spec ID and title,
- changed files summary,
- verification commands and results,
- commit hash if a commit was created,
- any residual risk.
