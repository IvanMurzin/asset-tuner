# Spec Workflow

All bugs, improvements, and features start as specs. A spec is a decision-complete implementation contract for one change.

## Directories
- `docs/specs/active/` - approved or draft specs not yet resolved.
- `docs/specs/resolved/` - completed or closed specs.
- `docs/specs/INDEX.md` - registry of all specs.

Keep `.gitkeep` files in empty directories.

## When To Create A Spec
Create a spec for:
- bug fixes with user-visible behavior,
- improvements that change UX, architecture, or contracts,
- new features,
- documentation or tooling changes that alter agent workflows.

Do not create a spec for:
- tiny typo fixes,
- pure formatting,
- exploratory questions where no implementation is requested.

## Numbering
Use the next integer in `SPEC-0001` format.

If `docs/specs/INDEX.md` is empty, start with `SPEC-0001`.
Otherwise, scan existing `SPEC-####` IDs and increment the highest number.

## Statuses
- `Draft` - spec is written but still has unresolved decisions.
- `Ready` - spec is decision-complete and can be implemented.
- `In Progress` - implementation has started.
- `Resolved` - implemented and verified.
- `Blocked` - cannot proceed without a named external decision, secret, account setup, or missing dependency.
- `Closed` - intentionally not implemented.

Only `Ready` specs should be implemented without further product questions.

## Types
- `bug`
- `improvement`
- `feature`
- `docs`
- `tooling`

## Priorities
- `P0` - critical correctness, build, data safety, or release blocker.
- `P1` - important product behavior or agent workflow issue.
- `P2` - normal improvement.
- `P3` - optional cleanup or polish.

## Spec File Template

```markdown
# SPEC-0001: Short Title

- **Type:** bug | improvement | feature | docs | tooling
- **Status:** Draft | Ready | In Progress | Resolved | Blocked | Closed
- **Priority:** P0 | P1 | P2 | P3
- **Owner:** human | codex | claude
- **Created:** YYYY-MM-DD
- **Resolved:** YYYY-MM-DD or empty

## Goal
One paragraph describing the outcome.

## User Or Product Impact
Who benefits and what changes for them.

## Current Behavior
What the current app/docs/backend does now. Cite files, routes, screens, or docs.

## Desired Behavior
The exact target behavior.

## Scope
What must change.

## Out Of Scope
What must not change.

## Constraints
Architecture, API, data, UX, localization, dependency, or compatibility constraints.

## Implementation Notes
Decision-complete guidance for the implementer. Include likely files only when useful.

## Acceptance Criteria
- [ ] Concrete observable result.
- [ ] Concrete observable result.

## Verification
- `command`
- Manual check when needed.

## Documentation Updates
Docs that must be updated when resolving this spec, or `None`.

## Rollout Notes
Migration, config, deploy, monitoring, or `None`.
```

## Creating Specs
1. Read `docs/README.md`, relevant product/tech/contracts docs, and the current code/doc files related to the request.
2. Classify the request as bug, improvement, feature, docs, or tooling.
3. Ask the user only for decisions that materially affect product behavior, architecture, API shape, data model, monetization, or rollout.
4. Write the spec to `docs/specs/active/SPEC-0001-short-title.md`.
5. Update `docs/specs/INDEX.md`.
6. Do not implement during spec creation unless the user explicitly asks to both create and resolve the spec.

## Resolving Specs
1. Read the selected spec, `docs/README.md`, relevant source-of-truth docs, and current code.
2. Stop before coding if the spec is not `Ready`, is ambiguous, or conflicts with current code in a way that needs product direction.
3. Set status to `In Progress`.
4. Implement only the spec scope.
5. Run the verification commands named in the spec, plus any required local checks for changed areas.
6. Update docs when behavior, architecture, API, or workflow changed.
7. Set status to `Resolved`, set resolved date, move the file to `docs/specs/resolved/`, and update `docs/specs/INDEX.md`.
8. Commit as `spec(SPEC-0001): short-summary`.

## Stop Conditions
Stop and report clearly when:
- required secrets/accounts/external dashboards are unavailable,
- verification fails and cannot be fixed within spec scope,
- the spec conflicts with architecture or source-of-truth docs,
- product behavior is under-specified,
- implementation would require unrelated refactors,
- generated files would need manual edits.

## Commit Format

```text
spec(SPEC-0001): short-summary
```
