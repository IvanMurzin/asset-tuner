---
name: "iterate-backlog"
description: "Execute exactly one backlog issue per run end-to-end: pick task, implement, self-review, update unified QA registry, and commit; if human decision is required, mark task Blocked with reason."
---

# Iterate Backlog (One Issue)

## Overview

Single-issue delivery loop for `docs/backlog/2026-03-product-quality-audit`:

1. pick one issue,
2. implement,
3. self-review and refine,
4. write to unified QA registry,
5. commit.

If safe autonomous completion is not possible, mark issue `Blocked` with a concrete reason and stop.

Default language for reports and QA steps: Russian.

## Trigger Phrases

Use for requests like:

- "итерация backlog"
- "take next backlog issue end-to-end"
- "solve one backlog task with review and commit"
- "сделай одну задачу из backlog под ключ"

## Input Contract

Expected input:

- optional explicit issue ID (example: `BUG-SUB-006`), or
- request to take next task from index.

If issue ID is not given, use deterministic picker from `references/task-selection.md`.

## Output Contract

Always deliver one of two outcomes.

1. `Done` outcome:
- issue implemented,
- issue status updated to `Done`,
- `INDEX.md` synchronized,
- unified QA registry updated,
- local commit created.

2. `Blocked` outcome:
- issue status updated to `Blocked`,
- `Blocked reason` documented in issue file,
- `INDEX.md` synchronized with `Blocked`,
- unified QA registry updated with blocked entry,
- commit created for docs-only status update.

## Required Workflow

1. Read source of truth before coding:
- `docs/README.md`
- `client/AGENTS.md`
- related contracts in `docs/contracts/*`
- selected issue file and `INDEX.md`

2. Select one target issue:
- explicit ID if provided and not `Done`, otherwise deterministic next from index.

3. Complexity/Human-decision gate:
- If task needs product/UX decision, unavailable secret/system, or has high ambiguity/risk that cannot be resolved safely in autonomous mode, switch to `Blocked` flow.

4. `Blocked` flow:
- set issue metadata `Статус: Blocked`,
- add section `## Blocked reason` with:
  - reason,
  - evidence,
  - exact unblock condition,
- update issue line in `INDEX.md` to include marker `` `Blocked` ``,
- append blocked record to QA registry,
- commit docs changes.

5. `Done` flow:
- implement only selected issue scope,
- run self-review on current diff using `references/review-rubric.md`,
- fix confirmed `blocker`/`high` issues,
- rerun checks from `references/quality-gates.md`,
- update issue doc:
  - `Статус: Done`,
  - `Implementation note` with changed files and checks,
- update corresponding line in `INDEX.md` with `` `Done` ``,
- append QA record to registry,
- commit all related changes.

6. Commit rule:
- commit message format: `backlog(<ISSUE-ID>): <short-summary>`.
- do not push unless user explicitly asks.

## Unified QA Registry

Registry path:

- `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`

For each iteration append entry with:

1. date/time,
2. issue ID,
3. final state (`Done` or `Blocked`),
4. commit hash,
5. auto checks and result,
6. manual QA checklist (for `Done`) or unblock steps (for `Blocked`).

## Hard Rules

- Exactly one backlog issue per run.
- Never hide failing checks.
- Never mark `Done` if AC is not actually satisfied.
- Never modify generated files manually (`*.g.dart`, `*.freezed.dart`).
- Do not run unrelated refactors.
- If blocked, always provide actionable unblock condition.

## Stop Conditions

Stop and report if:

- no non-`Done` and non-`Blocked` tasks remain,
- required files are missing/inconsistent,
- required tooling is unavailable,
- safe resolution is impossible without human decision.

In stop report include:

1. blocker,
2. what was verified,
3. minimal next user action.
