---
name: create-spec
description: Create a decision-complete Asset Tuner spec for a bug, improvement, feature, docs change, or tooling change; inspect repo/docs first, ask only material questions, write docs/specs/active/SPEC-####-*.md, and update docs/specs/INDEX.md.
---

# Create Spec

Use this skill when the user wants to turn an idea, bug report, improvement, or feature request into a repository spec.

## Source Of Truth
Read before writing:
- `docs/README.md`
- `docs/specs/README.md`
- relevant product docs in `docs/product/`
- relevant technical/contracts docs in `docs/tech/` or `docs/contracts/`
- current code/docs related to the request

## Workflow
1. Determine the spec type: `bug`, `improvement`, `feature`, `docs`, or `tooling`.
2. Inspect current behavior in repo files before asking questions.
3. Ask only for decisions that materially affect product behavior, architecture, API shape, data model, monetization, rollout, or acceptance criteria.
4. Allocate the next `SPEC-####` ID by scanning `docs/specs/INDEX.md` and existing spec files.
5. Create `docs/specs/active/SPEC-####-short-title.md` using the template in `docs/specs/README.md`.
6. Set status to `Ready` only when the spec is decision-complete. Otherwise set `Draft` and list unresolved decisions explicitly.
7. Update `docs/specs/INDEX.md`.

## Hard Rules
- Do not implement the change while creating the spec unless the user explicitly asks to create and resolve it in the same request.
- Treat current app/backend behavior as correct unless the user explicitly says it is wrong.
- Keep specs in English.
- Keep acceptance criteria observable and testable.
- Include verification commands suitable for the changed area.
- Do not create parallel task registries outside `docs/specs/`.

## Output
Report:
- spec ID,
- spec path,
- status,
- unresolved questions if status is `Draft`.
