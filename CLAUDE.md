# Asset Tuner

Asset Tuner is a Flutter mobile app backed by Supabase.

## Repository Map
- `client/` - Flutter app. Full client rules: `client/CLAUDE.md`.
- `backend/` - Supabase migrations, seed data, Edge Functions, and deploy scripts.
- `docs/` - product, technical, contract, UX, and spec workflow documentation.
- `.claude/commands/` - project slash commands.
- `.codex/skills/` - equivalent Codex workflows.

## Source Of Truth
- Documentation index: `docs/README.md`.
- Current product: `docs/product/overview.md` and `docs/product/capabilities.md`.
- Flutter architecture: `client/CLAUDE.md` and `docs/tech/client-architecture.md`.
- Backend/API contracts: `docs/contracts/data-contract.md` and `docs/contracts/api-surface.md`.
- Development workflow through specs: `docs/specs/README.md`.

Current code is the implementation truth. If documentation disagrees with the current app or backend, update the documentation unless the user explicitly says the code is wrong.

## Client Commands
Run from `client/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format .
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
flutter build apk --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build appbundle --flavor prod --release --dart-define-from-file=../.config.prod.json
```

## Hard Rules
- Feature work lives under `client/lib/` unless the spec explicitly changes backend/docs/tooling.
- Generated files are never edited manually: `*.freezed.dart`, `*.g.dart`, `client/lib/core/di/injectable.config.dart`, and generated localization files.
- User-visible strings go through `client/lib/l10n/app_en.arb` and `client/lib/l10n/app_ru.arb`; keep both in sync.
- Dart line length is 100.
- Do not add dependencies unless a spec explicitly requires them.
- Use the spec workflow for bugs, improvements, and features.

## Spec Workflow
- Create a new spec with `/create-spec`.
- Resolve a spec with `/resolve-spec SPEC-0001`.
- Active specs live in `docs/specs/active/`; resolved specs live in `docs/specs/resolved/`.
- Commit resolved work as `spec(SPEC-0001): short-summary`.
