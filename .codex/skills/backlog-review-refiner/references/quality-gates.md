# Quality Gates for Review Refinement

Run only commands relevant to changed files; always report each command result.

## Base Commands

When client code is touched:

```bash
cd client && flutter analyze
```

When tests exist for touched feature:

```bash
cd client && flutter test test/<targeted_test>.dart
```

When broad confidence is required and runtime is acceptable:

```bash
cd client && flutter test
```

## Failure Handling

If a command fails:

1. inspect failure,
2. fix if inside current scope,
3. rerun command.

If command cannot be run due to missing toolchain, explicitly mark as:

- `Not executed: environment limitation`

and include manual verification fallback.

## Commit-Readiness Rule

Never claim commit-ready if:

1. blocker/high findings remain unresolved,
2. mandatory analysis failed,
3. verification evidence is missing.
