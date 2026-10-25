# SPEC-0039: Fresh libapp In Release Builds

- **Type:** tooling
- **Status:** Resolved
- **Priority:** P0
- **Owner:** claude
- **Created:** 2026-10-25
- **Resolved:** 2026-10-25

## Goal
Close QA-044: an incremental local `flutter build apk|appbundle --release` must package the Dart
code that was just compiled.

## Current Behavior
`compileFlutterBuild<Variant>` writes a fresh `app.so`, `copyJniLibs…` syncs it to
`build/app/intermediates/flutter/<variant>/jniLibs/libapp.so`, but
`:app:merge<Variant>JniLibFolders` stays UP-TO-DATE and the APK/AAB ships the previous
`libapp.so`. The Flutter plugin adds that dir as a jniLibs source dir (`sourceSets.all`) and makes
the merge task `dependsOn` the copy, but with AGP 8.11 the dir does not invalidate the merge.
Reproduced: a changed log string was missing from the APK without the fix and present with it.
CI builds from a clean checkout and is not affected.

## Desired Behavior
`client/android/app/build.gradle.kts` adds Flutter's `jniLibs` dir (as a file tree, since debug
builds never create it) to the inputs of every `merge*JniLibFolders` task.

## Out Of Scope
Upstream Flutter or AGP changes.

## Acceptance Criteria
- [x] Probe: a Dart string change reaches the prod APK on an incremental build (it did not before).
- [x] `flutter build apk --flavor dev --debug` still builds.
- [x] `flutter build appbundle --flavor prod --release` contains the current Dart strings.

## Verification
Change a string, `flutter build apk --flavor prod --release …`, then
`unzip -p <apk> lib/arm64-v8a/libapp.so | strings | grep <string>`.

## Documentation Updates
`docs/tech/operations.md`, `docs/qa/findings.md` (QA-044).

## Rollout Notes
Any locally built release from before this fix may contain stale Dart code; rebuild before upload.
