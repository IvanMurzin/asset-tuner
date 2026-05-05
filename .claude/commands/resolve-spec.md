---
description: "Resolve one Asset Tuner spec end-to-end, verify it, move it to resolved, update the index, and commit."
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep]
---

# Resolve Spec

Use `docs/specs/README.md` as the workflow source of truth.

Required behavior:
1. Locate the requested spec in `docs/specs/INDEX.md`.
2. Read the spec, `docs/README.md`, relevant source-of-truth docs, and current code.
3. Stop if the spec is not `Ready`, is ambiguous, conflicts with architecture, needs unavailable secrets/accounts, or requires unrelated refactors.
4. Set the spec to `In Progress`, implement strictly within scope, and run the verification commands named in the spec.
5. Update docs if behavior, architecture, API, UX, operations, or workflow changed.
6. Set status to `Resolved`, move the spec to `docs/specs/resolved/`, update `docs/specs/INDEX.md`.
7. Commit as `spec(SPEC-####): short-summary`.

Never mark a spec resolved with failing or skipped mandatory checks unless the spec explicitly allows the skip and the final report explains it.
