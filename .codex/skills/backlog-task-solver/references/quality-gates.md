# Quality Gates

Choose commands based on changed area. Always report executed commands and outcome.

## Mandatory Minimum

For any client-impacting change:

```bash
cd client && flutter analyze
```

## Optional/Contextual Checks

Run when relevant to touched code:

```bash
cd client && flutter test
cd client && flutter test test/<targeted_test>.dart
cd client && dart run build_runner build --delete-conflicting-outputs
```

Backend-focused checks (if backend files changed and commands are available):

```bash
cd backend && ./scripts/deploy_supabase.sh --help
```

If backend has no fast local test/check command, explicitly mark as "not available in repo".

## Rule for Done State

Issue can be marked `Done` only when:

1. implementation satisfies acceptance criteria in issue doc,
2. mandatory checks passed,
3. any skipped checks are explained in `Implementation note`.

If a mandatory check fails, keep issue status unchanged and report blocker.
