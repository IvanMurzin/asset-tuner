# Run <YYYY-MM-DD>: <label>

- **Scope:** full | quick | <case list>
- **Commit under test:** `<hash>` (<branch>)
- **Backend:** the hosted Supabase project shared by dev and prod
- **Runner:** <agent/model>, following `docs/qa/regression-runbook.md`
- **Environment:** <JDK>, <AVD / Android version / keyboard>, <builds used>
- **Result:** <one line: go or no-go, open blockers>
- **Baseline:** plan counts `<free N / pro M>`, leftovers `0`
- **Cleanup:** <ids deleted>, leftovers after the run `0`, plan counts equal to the baseline: yes/no

## Release Gates
| Gate | Status | Notes |
|---|---|---|
| No open blocker findings | | |
| `health.sql` section 1 is empty | | |
| `qa/run.sh` fails only on accepted findings | | |
| Emulator E1–E8, E16, E17 pass | | |
| Device P1, P2, P4, L2, R1, S pass | | |

## Code Layer
`qa/run.sh`: <passed> passed, <failed> failed.

| # | Status | Finding / note |
|---|---|---|
| C1 | | |

## Emulator Layer
| # | Status | Finding | Evidence |
|---|---|---|---|
| E1 | | | |

## Device Layer (owner)
| # | Status | Finding | Notes |
|---|---|---|---|
| P1 | pending (owner) | | |

## Findings Changed In This Run
- New: <QA-NNN ...>
- Status changes: <QA-NNN: to-verify → confirmed-runtime ...>
- Verified fixed: <QA-NNN (SPEC-NNNN) ...>
