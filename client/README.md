# Asset Tuner Client

Flutter client for Asset Tuner.

## Common Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format .
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
```

Full development rules live in `client/AGENTS.md` and `client/CLAUDE.md`.
