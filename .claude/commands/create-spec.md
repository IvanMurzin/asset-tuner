---
description: "Create a decision-complete Asset Tuner spec and update docs/specs/INDEX.md."
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep]
---

# Create Spec

Use `docs/specs/README.md` as the workflow source of truth.

Required behavior:
1. Read `docs/README.md`, `docs/specs/README.md`, relevant product/tech/contracts docs, and current repo files related to the request.
2. Classify the request as `bug`, `improvement`, `feature`, `docs`, or `tooling`.
3. Ask only material product/architecture/API/data/rollout questions.
4. Allocate the next `SPEC-####` ID.
5. Write the spec to `docs/specs/active/`.
6. Update `docs/specs/INDEX.md`.

Do not implement while creating the spec unless the user explicitly asks for create-and-resolve in one request.
