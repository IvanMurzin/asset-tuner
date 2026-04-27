# Flavors, Bundle IDs и аккаунты

## Bundle / Application ID

| Flavor | Android applicationId | iOS bundle identifier | Deep link scheme | Подпись release |
|---|---|---|---|---|
| `dev`  | `developer.ivanmurzin.assettuner.dev` | `developer.ivanmurzin.assettuner.dev` | `assettunerdev`  | debug keystore |
| `prod` | `developer.ivanmurzin.assettuner`     | `developer.ivanmurzin.assettuner`     | `assettuner`     | release keystore (`client/android/key.properties`) |

Оба apk/ipa могут стоять на одном устройстве одновременно — bundle id отличаются.

---

## Аккаунты — текущее состояние (всё считаем prod)

- **Supabase**: проект, на который указывает `SUPABASE_URL` в `.config.prod.json` — это prod.
- **RevenueCat**: ключи (`REVENUECAT_API_KEY_*`) в `.config.prod.json` — prod project.
- **Apple Developer**: bundle id `developer.ivanmurzin.assettuner` — prod.
- **Google Play Console**: applicationId `developer.ivanmurzin.assettuner` — prod.

Сейчас `.config.dev.json` и `.config.prod.json` **используют одни и те же** Supabase/RevenueCat ключи. Это работает, но **не** даёт чистой изоляции prod-данных от экспериментов в dev. План разнести — ниже.

---

## Что нужно завести под dev (best practice, опционально)

### Supabase
- Создай новый проект `asset_tuner_dev` в той же организации.
- Скопируй URL + anon key → `.config.dev.json` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
- Накатить миграции: `supabase db push --project-ref <DEV_PROJECT_REF>` из `backend/`.
- Применить edge functions: `supabase functions deploy --project-ref <DEV_PROJECT_REF>`.

### RevenueCat
- В существующем аккаунте создай **второе App** (или второй Project) — `asset_tuner_dev`.
- Привяжи **два** платформенных приложения:
  - Google Play: `developer.ivanmurzin.assettuner.dev`
  - App Store: `developer.ivanmurzin.assettuner.dev`
- Скопируй platform-specific public SDK keys → `.config.dev.json`:
  - `REVENUECAT_API_KEY_ANDROID` (sandbox/test goog_…)
  - `REVENUECAT_API_KEY_IOS` (sandbox/test appl_…)

### Apple Developer Portal
- Зарегистрируй App ID `developer.ivanmurzin.assettuner.dev` (Identifiers → +).
- Включи нужные capabilities (In-App Purchase, Sign in with Apple — как у prod).
- Создай Development provisioning profile под dev bundle id (Xcode сделает это автоматически при первой сборке dev схемы, если включён automatic signing).
- **App Store Connect для dev НЕ заводи** — dev в стор не идёт.

### Google Play Console
- Для dev приложение в Play Console **не создаём**. Раздаём apk напрямую (через Drive / Diawi / Firebase App Distribution позже).
- Prod app в Play Console остаётся как сейчас.

### Аналитика (когда подключим SDK)
- Сейчас `AppAnalytics` — заглушка-логгер. Гейт работает: реально шлёт только когда `ANALYTICS_ENABLED=true`, `kReleaseMode=true`, `ANALYTICS_API_KEY` непустой.
- Под dev и prod заведи **разные** проекты в выбранном провайдере (Firebase / Amplitude / Mixpanel) — раздельные потоки событий.
- Ключи: `ANALYTICS_API_KEY` в соответствующем `.config.<flavor>.json`.
- В `.config.dev.json` оставляй `ANALYTICS_ENABLED: false` — dev в продовый поток слать не должен.

---

## Куда что заливать

| Артефакт | Куда |
|---|---|
| `prod release aab` | Google Play Console → внутренний / открытый / прод трек |
| `prod release ipa` | App Store Connect → TestFlight → Production |
| `dev release apk` | Раздать вручную (Drive / Diawi). Подписан debug-ключом, в стор не уйдёт |
| `dev release ipa` | TestFlight под dev bundle id (если нужен) — но только если завёл App Store Connect entry под dev (обычно не нужно) |

---

## Чек-лист ручной настройки Xcode (один раз)

В `ios/Runner.xcworkspace`:

1. **Configurations** (Project → Runner → Info → Configurations): продублировать `Debug`, `Release`, `Profile` в:
   - `Debug-dev`, `Release-dev`, `Profile-dev` — привязать к `Flutter/Debug-dev.xcconfig` / `Release-dev.xcconfig` / `Profile-dev.xcconfig`
   - `Debug-prod`, `Release-prod`, `Profile-prod` — привязать к соответствующим `*-prod.xcconfig`
2. **Schemes** (Product → Scheme → Manage Schemes): создать `dev` и `prod` (на основе Runner).
   - В каждой схеме на каждом этапе (Run/Test/Profile/Analyze/Archive) выставить соответствующую конфигурацию (`Debug-<flavor>`, `Release-<flavor>`, `Profile-<flavor>`).
   - Поставить ☑ Shared.
3. **Запуск**:
   ```bash
   cd client
   flutter run --flavor dev  --dart-define-from-file=../.config.dev.json
   flutter run --flavor prod --dart-define-from-file=../.config.prod.json
   ```

> Эти шаги ручные потому что `project.pbxproj` редактировать программно из этого репо рискованно — Xcode-конфиги хранятся в нём бинарно-структурированно.

---

## GitHub Secrets для CI билдов

Для `.github/workflows/client_build.yml` (manual dispatch) нужны секреты:

| Secret | Что |
|---|---|
| `CONFIG_DEV_JSON`  | Полное содержимое `.config.dev.json` |
| `CONFIG_PROD_JSON` | Полное содержимое `.config.prod.json` |
| `RELEASE_KEYSTORE_BASE64` | `base64 -i client/android/keystores/release.keystore` (только для prod release) |
| `RELEASE_KEY_ALIAS` | alias из `key.properties` |
| `RELEASE_KEY_PASSWORD` | пароль ключа |
| `RELEASE_STORE_PASSWORD` | пароль keystore |

iOS-сборка в CI **не выполняется** (нет macOS runner на free plan + provisioning сложно).

---

## Firebase (Analytics + Crashlytics)

Firebase подключён **только для prod-флавора** на обеих платформах. Dev-сборки идут без Firebase — `FirebaseInitializer` (`client/lib/core/firebase/firebase_initializer.dart`) проверяет `AppConfig.firebaseEnabled` и пропускает init для dev.

**Где лежат конфиги (gitignored):**

| Платформа | Путь | Bundle / package |
|---|---|---|
| Android prod | `client/android/app/src/prod/google-services.json` | `developer.ivanmurzin.assettuner` |
| iOS prod | `client/ios/Runner/GoogleService-Info.plist` | `developer.ivanmurzin.assettuner` |

Firebase project: `assettuner-8dc26`.

**Android:** Gradle-плагины `com.google.gms.google-services` + `com.google.firebase.crashlytics` применяются динамически только для prod-задач (`isProdTaskRequested` в `client/android/app/build.gradle.kts`). Dev-сборки не требуют json и не падают, если он отсутствует.

**iOS:** `GoogleService-Info.plist` зарегистрирован в Resources таргета Runner и попадает в bundle всех конфигураций. Init Firebase в Dart всё равно вызывается только для prod-флавора, поэтому в dev-сборках plist не читается.

**Crashlytics активируется только в `kReleaseMode`** — в debug никаких отчётов не уходит. Хуки: `FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`.

**Аналитика** (`AppAnalytics`, `lib/core/analytics/app_analytics.dart`) пишется в Firebase Analytics, гейт `AppConfig.analyticsActive = firebaseEnabled && analyticsEnabled && kReleaseMode`. В debug события только логируются в консоль.

**`setUserId`** вызывается из `SessionCubit` после логина и при logout — связывает события и crash-репорты с Supabase user id.

### Локальное тестирование Analytics (DebugView)

```bash
adb shell setprop debug.firebase.analytics.app developer.ivanmurzin.assettuner
flutter run --flavor prod --release --dart-define-from-file=../.config.prod.json
```
События появятся в Firebase Console → Analytics → DebugView в реальном времени. Сбросить: `adb shell setprop debug.firebase.analytics.app .none.`

### Crashlytics smoke-test

В release-сборке временно бросьте необработанное исключение после загрузки приложения, перезапустите — отчёт появится в Firebase Console → Crashlytics через 5–10 минут.

### Если потребуется Firebase для dev

1. В Firebase Console → проект `assettuner-8dc26` добавить Android-app `developer.ivanmurzin.assettuner.dev` и iOS-app `developer.ivanmurzin.assettuner.dev`.
2. Скачать новые `google-services.json` и `GoogleService-Info.plist`.
3. Положить:
   - `client/android/app/src/dev/google-services.json`
   - заменить iOS plist на скрипт-копирование per-flavor (через Build Phase, см. flutterfire docs).
4. В `app_config.dart` снять ограничение `firebaseEnabled = flavor == AppFlavor.prod` (например, `firebaseEnabled = true`).
5. Снять флавор-гейт с Gradle-плагинов в `android/app/build.gradle.kts`.
