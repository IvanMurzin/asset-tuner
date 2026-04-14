---
name: backlog-review-refiner
description: Review current uncommitted code changes, classify risks by severity, fix confirmed issues, rerun checks, and return a concise quality report with manual QA steps. Use when the user asks to review changed code and refine it before commit. Triggers include RU/EN phrases like "сделай ревью изменений", "поревьюй и доработай", "review current diff", "review and fix changed code".
---

# Backlog Review Refiner

## Overview

Perform review+autofix on current git working tree changes and return a commit-readiness report.

Default language for findings and manual checks: Russian.

## Trigger Phrases

Activate for requests such as:

- "Сделай ревью измененного кода"
- "Поревьюй и доработай перед коммитом"
- "Review current diff"
- "Review and auto-fix issues"

## Input Contract

Default review base:

- current uncommitted `git diff`

Optional user-provided scope:

- subset of files or modules
- explicit risk focus

## Output Contract

Always return sections:

1. `Found`: issues grouped by severity (`blocker`, `high`, `medium`).
2. `Fixed`: concrete fixes made in changed files.
3. `Remaining risks`: unresolved items and impact.
4. `Manual checks`: short runbook for user validation.
5. `Auto checks`: exact commands and outcomes.

## Required Workflow

1. Collect patch context:
   - `git status --short`
   - `git diff`
2. Review using rubric in `references/review-rubric.md`.
3. Prioritize by severity:
   - fix `blocker` and `high` first,
   - fix `medium` when low-risk and clear.
4. Apply fixes directly in changed files.
5. Rerun relevant checks via `references/quality-gates.md`.
6. Produce structured final report.

## Hard Rules

- Never run `git add`, `git commit`, `git push`.
- Do not rewrite unrelated code.
- Do not suppress findings without rationale.
- If uncertain, keep note in `Remaining risks`.
- Respect project architecture constraints from `client/AGENTS.md`.

## Stop Conditions

Stop and report if:

- no changed files exist (`git diff` empty),
- environment lacks required check toolchain,
- issue is ambiguous and unsafe to auto-fix.

In stop cases return:

1. blocker,
2. available evidence,
3. minimal next action.

## Validation and Reliability Loop

Run this loop:

1. Find risks.
2. Fix deterministic issues.
3. Re-check.
4. Re-evaluate diff for regressions.
5. Finalize report.

Use `references/agent-practices.md` for workflow discipline.
