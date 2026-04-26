# Asset Tuner

Mobile app (Flutter) + Backend (Supabase).

## Repository structure
- `client/` — Flutter app
- `backend/` — Supabase (migrations, edge functions)
- `docs/` — product documentation

## Client: full rules
@client/AGENTS.md

## Client: key commands
```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format .
flutter test
flutter run
```

## Working in this repo
- All feature work lives in `client/lib/`
- Generated files (`*.freezed.dart`, `*.g.dart`) are never edited manually — run codegen
- Line length: 100 (see analysis_options.yaml)
- Localization strings: `client/lib/l10n/app_en.arb` + `app_ru.arb` (both must stay in sync)

## Backlog workflow
- Backlog: `docs/backlog/2026-03-product-quality-audit/`
- Index: `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- QA Registry: `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Commit format: `backlog(<ISSUE-ID>): <short-summary>`
