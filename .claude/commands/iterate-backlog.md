---
description: "Взять одну задачу из backlog и выполнить end-to-end: implement или Blocked, обновить INDEX и issue-файл, записать в QA Registry, создать коммит."
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep]
---

# Iterate Backlog (One Issue)

## Trigger phrases
- "итерация backlog"
- "iterate backlog"
- "сделай одну задачу из backlog"
- "take next backlog issue"

## Overview

Single-issue delivery loop for `docs/backlog/2026-03-product-quality-audit`:

1. прочитать source-of-truth,
2. выбрать одну задачу,
3. оценить сложность (human-decision gate),
4. реализовать или пометить Blocked,
5. self-review на diff,
6. quality gates,
7. обновить issue-файл и INDEX.md,
8. записать в QA Registry,
9. коммит.

Default language for reports and QA entries: **Russian**.

---

## Step 1 — Read source of truth before coding

Before touching any code, read:

- @docs/README.md
- @client/AGENTS.md
- @docs/backlog/2026-03-product-quality-audit/INDEX.md
- selected issue file (after selection in Step 2)

---

## Step 2 — Select one target issue

If an issue ID was provided explicitly in the prompt — use it (if not `Done`/`Blocked`).

Otherwise apply the **deterministic picker**:

### Task selection algorithm

Source files:
- `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- `docs/backlog/2026-03-product-quality-audit/issues/*.md`

**Section order:**
1. `CONF` → 2. `AUTH` → 3. `DS` → 4. `CUR` → 5. `SUB` → 6. `PRO` → 7. `ANA` → 8. `SUP`

**Priority inside section:**
1. `P0` → 2. `P1` → 3. `P2`

**Tie-breaker:** appearance order in `INDEX.md`.

**Eligibility:**
- issue file exists
- status is **not** `Done` and **not** `Blocked`

Status source of truth — line in issue file: `- Статус: \`...\``
`INDEX.md` is a projection; sync it after each run.

---

## Step 3 — Human-decision gate

If the task requires:
- product/UX decision without spec,
- unavailable secret or external system,
- high ambiguity or unacceptable risk for autonomous completion,

→ switch to **Blocked flow** (Step 4).

Otherwise → **Done flow** (Step 5).

---

## Step 4 — Blocked flow

1. Set issue metadata: `Статус: Blocked`
2. Add section `## Blocked reason` with:
   - reason,
   - evidence,
   - exact unblock condition.
3. Update issue line in `INDEX.md`: add `` `Blocked` `` marker.
4. Append blocked record to QA Registry (see Step 8 format).
5. Commit docs-only changes.

---

## Step 5 — Done flow (implementation)

Implement **only** the selected issue scope. No unrelated refactors.

### Quality gates

Run only relevant checks; always report exact command output.

**Mandatory for any client-impacting change:**
```bash
cd client && flutter analyze
```

**Optional/contextual:**
```bash
cd client && flutter test test/<targeted_test>.dart
cd client && flutter test
cd client && dart run build_runner build --delete-conflicting-outputs
```

**Backend-only changes:**
```bash
cd backend && ./scripts/deploy_supabase.sh --help
```

If a tool is unavailable: report as `Not executed: environment limitation`.

**Gate for Done:** issue can be marked Done only if:
1. acceptance criteria satisfied,
2. mandatory checks passed,
3. any skipped checks explicitly justified.

If mandatory checks fail and cannot be fixed safely in scope → switch to Blocked.

---

## Step 6 — Self-review

Review current diff before finalizing state.

### Severity levels
- `blocker` — data loss, crash, broken route/flow, contract break
- `high` — clear incorrect behaviour, strong regression risk
- `medium` — maintainability/test gap with moderate risk

### Review checklist
1. **Scope control:** no unrelated changes.
2. **Acceptance criteria:** covered and testable.
3. **Contracts/config:** synchronized when affected.
4. **Localization:** `app_en.arb` and `app_ru.arb` updated when UI copy changed.
5. **Navigation/state:** no obvious regressions.
6. **Tests/checks:** relevant checks executed and reported.

### Action rule
1. Fix all `blocker` and `high` findings.
2. Fix `medium` when low-risk and deterministic.
3. Keep unresolved items only with explicit rationale in final report.

---

## Step 7 — Update issue file and INDEX.md

**Done:**
- Set `Статус: Done`
- Add `## Implementation note` with: changed files list, checks run and results.
- Update issue line in `INDEX.md`: add `` `Done` `` marker.

**Blocked:**
- Set `Статус: Blocked`
- Add `## Blocked reason` (see Step 4).
- Update `INDEX.md` with `` `Blocked` `` marker.

---

## Step 8 — Append to QA Registry

File: `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`

Append one entry per run:

```markdown
## <ISSUE-ID> — <Done|Blocked> — <YYYY-MM-DD HH:MM>

- **Issue:** <issue title>
- **Commit:** <hash after commit, or "pending">
- **Auto checks:** <command and result, or "Not executed: environment limitation">
- **Final state:** Done | Blocked

### Manual QA (для Done)
- [ ] <проверка 1>
- [ ] <проверка 2>

### Unblock steps (для Blocked)
- <шаг 1>
```

---

## Step 9 — Commit

**Commit message format:** `backlog(<ISSUE-ID>): <short-summary>`

Example: `backlog(BUG-ANA-001): fix backend analytics endpoint`

Rules:
- Commit ALL related changes: code + docs (issue file + INDEX.md + QA Registry).
- Do **not** push unless user explicitly asks.

---

## Hard rules

- Exactly one backlog issue per run.
- Never hide failing checks.
- Never mark Done if AC is not actually satisfied.
- Never modify generated files manually (`*.g.dart`, `*.freezed.dart`).
- Do not run unrelated refactors.
- If blocked, always provide actionable unblock condition.

---

## Stop conditions

Stop and report if:
- no eligible tasks remain (all Done/Blocked),
- required files are missing or inconsistent,
- required tooling is unavailable,
- safe resolution is impossible without human decision.

Stop report must include:
1. blocker,
2. what was verified,
3. minimal next user action.
