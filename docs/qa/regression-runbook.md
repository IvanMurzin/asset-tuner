# Regression Runbook

This is the procedure an agent (Claude Code or Codex) follows when the owner says "run the
regression" or invokes `/regress`. It produces one run report in `docs/qa/runs/` and updates
`docs/qa/findings.md`. Follow the steps in order. When something cannot be run, say so in the
report; never mark a case `pass` without evidence.

## 0. Inputs
- **Scope:** `full` by default. With `quick`, run only the code layer plus E1, E2, E5, E6, E8 and
  E16. A named list of cases, such as `E18-E28`, runs just those.
- **Label:** a short run name, for example `android-1.0.1`. The report is written to
  `docs/qa/runs/<YYYY-MM-DD>-<label>.md`.
- **Target:** the current `HEAD`. Record the commit hash.

## 1. Preconditions
Check each of these and report anything missing before starting:

| Need | Check |
|---|---|
| Config files | `.config.dev.json`, `.config.prod.json` and `backend/.env` exist. Never print their values. |
| Supabase CLI login | `cd backend && supabase projects api-keys --project-ref "$SUPABASE_PROJECT_REF" -o json` lists key names |
| Tools | `deno`, `psql`, `python3`, `flutter` |
| JDK for Gradle 8.14 | `flutter config --list` shows a `jdk-dir` of JDK 17–24 (21 is known to work). Java 25 cannot run Gradle 8.14 (QA-031). |
| Android | `~/Library/Android/sdk/emulator/emulator -list-avds` shows an AVD (the first run used `Medium_Phone`) |

Permission note:
- Loading project secrets and querying the production database can prompt for approval in auto
  mode. Ask the owner once, up front.
- All writes go through disposable QA users (see `qa/README.md`).

## 2. Baseline
1. Run `git status`, and record the HEAD commit and branch.
2. Load the env (`set -a; source backend/.env; set +a`), then run
   `psql "$SUPABASE_DB_URL" -X -f qa/sql/health.sql`.
   - Record section 1 (grants), sections 3–5 (cron and rates freshness), section 6 (plan
     counts: the baseline), and section 10 (leftovers must be 0 before starting).
   - If section 10 shows leftovers from an earlier run, clean them up first (step 7).

## 3. Code Layer
1. Run `qa/run.sh`, which takes about 2 minutes. Record the pass and fail counts.
2. For every failure:
   - If it maps to a known finding, reference it.
   - If it is new, investigate it: is the test wrong, or is it a real regression? Fix the test, or
     add a finding.
3. The cases are listed in `docs/qa/cases/code.md`.

## 4. Emulator Layer
Setup:
```bash
~/Library/Android/sdk/emulator/emulator -avd Medium_Phone -no-snapshot-save -no-audio -no-boot-anim   # background
cd client && flutter build apk --flavor dev --debug --dart-define-from-file=../.config.dev.json
adb uninstall developer.ivanmurzin.assettuner.dev   # fresh install for E1
adb install -r build/app/outputs/flutter-apk/app-dev-debug.apk
```

Drive the app with `qa/emulator/ui.py`. Run `dump` before tapping, `hidekb` instead of back, and
`shot <name>` for evidence. Seed data and revoke sessions with `qa/emulator/user_api.ts`.

Run every case in `docs/qa/cases/emulator.md` within scope, in order, reusing state between
cases:
- E1–E8 build up the main user.
- E18–E24 need a second fresh free user.
- E16 deletes a user, so run it last for each user.

Then run E17 on the prod release build:
```bash
cd client && flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json
```

For each case, record the status, the finding ids, and one line of evidence.

## 5. Device Layer
The agent does not run `docs/qa/cases/device.md`. Instead:
- list the device cases in the report as `pending (owner)`;
- if the owner is running them in the same session, watch the database with the SQL helpers in
  that file and record what you observe.

## 6. Findings
- Update statuses in `docs/qa/findings.md`:
  - `to-verify` → `confirmed-runtime` or `not-reproduced`;
  - a fixed item → note `Resolved in SPEC-NNNN (verified in run <date>)`.
- Append new findings with the next `QA-NNN` id, using the format in `docs/qa/README.md`.
- Never delete findings.

## 7. Cleanup (mandatory)
1. Collect the ids of every user created during the run:
   `select id, email from auth.users where email like 'qa+%'`. Include the ids recorded before E16.
2. Run `qa/run.sh tool qa/tools/delete_users.ts <id> [<id> ...]`. It refuses non-QA users.
3. Re-run sections 6 and 10 of `health.sql`. Expect plan counts equal to the baseline and 0
   leftovers.
4. Close the emulator and leave uninstalled builds as they are. Remove any scratch credential
   files.

## 8. Report
- Copy `docs/qa/runs/TEMPLATE.md` to `docs/qa/runs/<date>-<label>.md` and fill in:
  - the header;
  - the release gates;
  - the code, emulator and device tables;
  - the new findings;
  - the cleanup proof.
- In chat, give the owner:
  - the gate status (go or no-go);
  - new or changed findings;
  - which device cases the owner still has to run.
- Commit only when the owner asks. Use the message
  `qa(regression): <label> run` and do not add a Co-Authored-By trailer.

## Release Gates (default)
Every gate must be `pass`, or explicitly accepted by the owner, before a production rollout:

1. No `blocker` finding is open.
2. Section 1 of `qa/sql/health.sql` returns 0 rows: no `api_*` function is exposed to
   `anon` or `authenticated`.
3. `qa/run.sh` fails only on findings the owner has accepted.
4. Emulator E1–E8, E16 and E17 pass, with no crash.
5. Device P1, P2, P4 (first two rows), L2, R1 and S pass.
