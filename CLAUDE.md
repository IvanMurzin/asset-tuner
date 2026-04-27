# Asset Tuner

Mobile app (Flutter) + Backend (Supabase).

## Repository structure
- `client/` — Flutter app
- `backend/` — Supabase (migrations, edge functions)
- `docs/` — product documentation

## Client: full rules
@client/CLAUDE.md

## Client: key commands
```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format .
flutter test
# Run/build всегда через flavor + config:
flutter run        --flavor dev  --dart-define-from-file=../.config.dev.json
flutter run        --flavor prod --dart-define-from-file=../.config.prod.json
flutter build apk        --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build appbundle  --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build apk        --flavor dev  --release --dart-define-from-file=../.config.dev.json
```

## Flavors
- Два flavor: `dev` и `prod`. Bundle id: `developer.ivanmurzin.assettuner.dev` / `developer.ivanmurzin.assettuner`.
- Конфиги в корне репозитория: `.config.dev.json`, `.config.prod.json` (gitignored), шаблоны `*.example`.
- Dev release подписывается debug keystore; prod release требует `client/android/key.properties`.
- Аналитика реально шлётся только когда `ANALYTICS_ENABLED=true && kReleaseMode && ANALYTICS_API_KEY != ''` — см. `client/lib/core/analytics/app_analytics.dart`.
- Подробности про аккаунты, иконки, Xcode-схемы и CI: `docs/flavors-and-accounts.md`.

## Working in this repo
- All feature work lives in `client/lib/`
- Generated files (`*.freezed.dart`, `*.g.dart`) are never edited manually — run codegen
- Line length: 100 (see analysis_options.yaml)
- Localization strings: `client/lib/l10n/app_en.arb` + `app_ru.arb` (both must stay in sync)

## Backlog workflow
- Backlog: `docs/backlog/2026-03-product-quality-audit/`
- Index: `docs/backlog/2026-03-product-quality-audit/INDEX.md`
- QA Registry: `docs/backlog/2026-03-product-quality-audit/QA-REGISTRY.md`
- Command: `/iterate-backlog` — pick one task and deliver end-to-end
- Commit format: `backlog(<ISSUE-ID>): <short-summary>`
