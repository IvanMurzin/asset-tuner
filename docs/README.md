# Asset Tuner Documentation

This folder is the source of truth for product intent, architecture, contracts, operations, UX, and spec-driven development.

The current app and backend are treated as correct unless the user explicitly says otherwise. When code and docs disagree, update the docs or create a spec for the intentional change.

## Start Here
- Product overview: `docs/product/overview.md`
- Product capabilities: `docs/product/capabilities.md`
- UX map: `docs/ux/screen-map.md`
- Client architecture: `docs/tech/client-architecture.md`
- Backend architecture: `docs/tech/backend-architecture.md`
- Data contract: `docs/contracts/data-contract.md`
- API surface: `docs/contracts/api-surface.md`
- Spec workflow: `docs/specs/README.md`

## Documentation Rules
- Keep docs in English.
- Prefer a small number of stable source-of-truth documents over duplicated feature notes.
- Product docs describe current behavior only. Future ideas belong in `docs/specs/active/`.
- Technical docs describe implementation contracts and agent rules precisely enough for Codex and Claude Code to follow without inventing architecture.
- Paths, route names, schema fields, and commands must be exact.

## Spec-Driven Development
All bugs, improvements, and features start as specs:

1. Create a spec in `docs/specs/active/` and update `docs/specs/INDEX.md`.
2. Implement strictly from the approved spec.
3. Verify with the commands named in the spec.
4. Update product/technical docs when behavior or contracts change.
5. Move the spec to `docs/specs/resolved/` and update the index.

Use `$create-spec` / `$resolve-spec` in Codex or `/create-spec` / `/resolve-spec` in Claude Code.
