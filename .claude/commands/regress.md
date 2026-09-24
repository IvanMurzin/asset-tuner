---
description: "Run the Asset Tuner regression (code + emulator layers), update findings, clean up QA data, and write a run report."
argument-hint: "[full|quick|<case list>] [label]"
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep]
---

# Regress

Use `docs/qa/regression-runbook.md` as the procedure source of truth, and follow it step by step.

Arguments: `$ARGUMENTS`
- The first token is the scope: `full` (the default), `quick`, or a case list such as `E18-E28` or `C21,E16`.
- The second token is the run label, for example `android-1.0.1`. Default: `regression`.

Required behavior:
1. Read `docs/qa/README.md`, `docs/qa/regression-runbook.md`, `docs/qa/findings.md`, and the case
   files in `docs/qa/cases/` that are in scope.
2. Check the preconditions (runbook §1). Report anything missing before running any writes.
   Ask once, up front, for approval to load project secrets and query the production database.
3. Record the baseline with `qa/sql/health.sql` (runbook §2).
4. Code layer: run `qa/run.sh` and map every failure to a finding (runbook §3).
5. Emulator layer: run the in-scope E cases with `qa/emulator/ui.py` and `qa/emulator/user_api.ts`
   (runbook §4). Collect evidence for each failure.
6. Do not run device cases. List them as `pending (owner)` (runbook §5).
7. Update `docs/qa/findings.md` (runbook §6).
8. Cleanup is mandatory: hard-delete every QA user created during the run and prove there are 0
   leftovers and baseline plan counts (runbook §7).
9. Write `docs/qa/runs/<date>-<label>.md` from `TEMPLATE.md`, then report the gate status, the
   findings that changed, and the device cases the owner still has to run (runbook §8).

Hard rules:
- Never print or commit secrets from `backend/.env` or `.config.*.json`.
- Write data only through disposable `qa+…@asset-tuner.test` users; never touch real users.
- Only `qa/tools/delete_users.ts` may delete users, and it refuses non-QA users.
- Never mark a case `pass` without evidence. Report skipped cases with the reason.
- Commit only when asked: `qa(regression): <label> run`, with no Co-Authored-By trailer.
