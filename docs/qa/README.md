# QA

Regression testing for Asset Tuner. Android is the first production platform.

## Run A Regression
Open a new agent chat in this repository and either:

- invoke **`/regress`** in Claude Code (`$regress` in Codex), optionally with a scope and label,
  for example `/regress full android-1.0.1` or `/regress E18-E28 gaps`; or
- say "run the regression following `docs/qa/regression-runbook.md`".

The agent then:
1. runs the code layer;
2. runs the emulator layer on dev debug and prod release builds;
3. updates the findings;
4. cleans up all QA data;
5. writes a report in `runs/`;
6. tells the owner which device cases are left.

## Layout
| Path | What it is |
|---|---|
| `regression-runbook.md` | The step-by-step procedure the agent follows, including the release gates |
| `cases/code.md` | Automated API and database cases (C#), run by `qa/run.sh` and `qa/sql/health.sql` |
| `cases/emulator.md` | UI cases (E#) an agent runs on the Android emulator with the dev flavor and Test Store |
| `cases/device.md` | Cases only the owner can run on a real phone (P, L, R, D, S, X): Google Play Billing, real OAuth, keyboards, store listing |
| `runs/` | One report per regression run. `TEMPLATE.md` is the starting point. |
| `findings.md` | Every bug, risk, UX note and improvement, with stable `QA-NNN` ids, ready to turn into specs |

Tooling lives in `qa/` at the repository root:
- API suite and runner: `qa/run.sh`, `qa/api/`;
- production health SQL: `qa/sql/health.sql`;
- emulator driver: `qa/emulator/ui.py`;
- user-level seeding: `qa/emulator/user_api.ts`;
- cleanup: `qa/tools/delete_users.ts`.

See `qa/README.md`.

## Test Layers
| Layer | Tool | Scope |
|---|---|---|
| Code | `qa/` Deno suite and `health.sql` | API contracts, validation, plan limits, isolation, billing webhook and refresh, grants, production health |
| Emulator | dev flavor with RevenueCat Test Store, driven over `adb` | UI flows, navigation, localization, error and offline states, paywall logic; prod release smoke |
| Device | Real phone, prod build from the Play internal track | Google Play Billing lifecycle, Google OAuth, deep links, real keyboards, store listing |

## Finding Format
Each entry in `findings.md` has:

- **Severity**: `blocker` (must fix before release), `high`, `medium`, `low`, `info`.
- **Type**: `bug`, `security`, `ux`, `improvement`, `docs`.
- **Status**:
  - `confirmed-runtime`: reproduced;
  - `confirmed-code`: certain from reading the code;
  - `to-verify`: a strong suspicion that still needs a run;
  - `not-reproduced`.
- **Area**, **Repro**, **Expected**, **Actual**, **Evidence**, **Suggested fix**.

Fixed items stay in the file with `Resolved in SPEC-NNNN` and the run that verified the fix.

## From Finding To Fix
1. Pick findings, blockers first, and turn them into specs with `/create-spec` (cite the `QA-NNN`).
2. Resolve them with `/resolve-spec SPEC-NNNN`.
3. Re-run the affected cases, for example `/regress C21,E16 verify-qa-002`, and mark the findings
   as resolved.
