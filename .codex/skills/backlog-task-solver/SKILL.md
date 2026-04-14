---
name: backlog-task-solver
description: Solve the next product-quality backlog task end-to-end and prepare commit-ready changes. Use when the user asks to take the next issue from docs/backlog/2026-03-product-quality-audit/INDEX.md, implement it, update backlog docs status from Draft to Done, run checks, and provide manual QA steps in chat. Triggers include RU/EN phrases like "возьми задачу из backlog", "сделай следующую задачу", "take next backlog item", "finish backlog issue".
---

# Backlog Task Solver

## Overview

Execute one backlog issue from selection to commit-ready state using deterministic picking, source-of-truth contracts, and explicit validation output.

Default language for summary and manual checks: Russian.

## Trigger Phrases

Use this skill when user intent matches one of these:

- "Возьми следующую задачу из backlog"
- "Сделай задачу из INDEX.md"
- "Закрой issue из product quality audit"
- "Take next backlog issue"
- "Pick next task from INDEX and implement"

## Input Contract

Expected input:

- Optional explicit issue ID (for example `BUG-DS-001`)
- Otherwise: "take next backlog task"

If issue ID is not provided, choose task via deterministic algorithm in `references/task-selection.md`.

## Output Contract

Always return:

1. Completed implementation (code/docs) for exactly one issue.
2. Updated issue doc:
   - `Статус: Done`
   - `Implementation note` block with what changed, modified files, checks.
3. Updated `INDEX.md` line for that issue with `Done`.
4. Validation report:
   - Auto checks executed
   - Pass/fail status
   - Any skipped checks with reasons
5. Manual QA checklist in chat.

## Required Workflow

Follow these steps in order.

1. Read source of truth before coding:
   - `docs/README.md`
   - `client/AGENTS.md`
   - relevant contracts in `docs/contracts/*`
   - selected issue file and `INDEX.md`
2. Select target issue:
   - If user provided ID: validate existence and status.
   - Else run deterministic picker from `references/task-selection.md`.
3. Implement issue scope only:
   - Respect architecture and existing patterns.
   - Do not introduce unrelated refactors.
4. Update backlog docs:
   - Set issue `Статус: Done`.
   - Add/update `Implementation note` with concrete evidence.
   - Mark corresponding entry in `INDEX.md` as `Done`.
5. Run quality gate:
   - Use command matrix in `references/quality-gates.md`.
   - Minimum for client-impacting changes: `cd client && flutter analyze`.
6. Produce final chat report:
   - What was changed
   - What was auto-verified
   - What user should verify manually
   - Any residual risks

## Hard Rules

- Never run `git add`, `git commit`, `git push`.
- Never mark issue as `Done` if implementation is incomplete.
- Never hide failing checks; report exact failing command.
- Do not edit generated files manually (`*.g.dart`, `*.freezed.dart`).
- Keep one issue per run unless user explicitly requests batch mode.

## Stop Conditions

Stop and report clearly if:

- No available non-`Done` issues remain.
- Required files/paths are missing or inconsistent.
- Required check command is unavailable in environment.
- Scope depends on unavailable secrets/external systems.

When stopped, provide:

1. precise blocker,
2. what was already done,
3. minimal next step for user.

## Validation and Reliability Loop

Use the loop below for every task:

1. Plan minimal change.
2. Implement.
3. Run checks.
4. Compare result against issue acceptance criteria.
5. If mismatch, iterate once more before final report.

Detailed reliability guardrails: `references/agent-practices.md`.
