---
name: regress
description: Run the Asset Tuner regression — automated API/DB suite (qa/run.sh, qa/sql/health.sql) and Android emulator cases (qa/emulator/ui.py) — update docs/qa/findings.md, hard-delete all QA data, and write a run report in docs/qa/runs/. Device (Google Play Billing) cases are listed for the owner, not run.
---

# Regress

Use this skill when the user asks to run the regression, re-test before a release, or verify fixed QA findings.

## Source Of Truth
- `docs/qa/regression-runbook.md`: the procedure. Follow it step by step.
- `docs/qa/README.md`: the layout and the finding format.
- `docs/qa/cases/code.md`, `docs/qa/cases/emulator.md`, `docs/qa/cases/device.md`: the case catalogs.
- `docs/qa/findings.md`: known issues (`QA-NNN`).
- `qa/README.md`: tooling and safety rules.

## Arguments
- Scope: `full` (default), `quick`, or a case list such as `E18-E28` or `C21,E16`.
- Label: the run name used in `docs/qa/runs/<date>-<label>.md`.

## Workflow
1. Check the preconditions (runbook §1) and ask once for approval to load secrets and query the production database.
2. Baseline with `qa/sql/health.sql`.
3. Run `qa/run.sh`; map failures to findings.
4. Run the in-scope emulator cases; collect evidence.
5. List the device cases as `pending (owner)`.
6. Update findings, clean up all QA users (`qa/run.sh tool qa/tools/delete_users.ts <ids>`), and prove 0 leftovers.
7. Write the run report from `docs/qa/runs/TEMPLATE.md` and summarize the gate status for the owner.

## Hard Rules
- Never print or commit secrets.
- Write only through disposable `qa+…@asset-tuner.test` users.
- Never mark a case `pass` without evidence.
- Commit only when asked: `qa(regression): <label> run`, with no Co-Authored-By trailer.
