# Quality Gates

Run only relevant checks and always report exact command outcomes.

## Mandatory Minimum

For any client-impacting change:

```bash
cd client && flutter analyze
```

## Optional/Contextual

```bash
cd client && flutter test test/<targeted_test>.dart
cd client && flutter test
cd client && dart run build_runner build --delete-conflicting-outputs
```

Backend-focused verification when backend files changed:

```bash
cd backend && ./scripts/deploy_supabase.sh --help
```

If command/tool is unavailable, report as:

- `Not executed: environment limitation`

## Gate for Done

Issue may be marked `Done` only if:

1. acceptance criteria are satisfied,
2. mandatory checks passed,
3. skipped checks are explicitly justified.

If mandatory checks fail and cannot be fixed safely in scope, switch to `Blocked`.
