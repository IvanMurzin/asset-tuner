# SPEC-0026: Pin Android JDK 21

- **Type:** tooling
- **Status:** Resolved
- **Priority:** P3
- **Owner:** claude
- **Created:** 2026-10-24
- **Resolved:** 2026-10-24

## Goal
Close QA-031: Android builds use JDK 21 regardless of the machine's default JDK.

## Current Behavior
Gradle 8.14.3 cannot run on Java 25 (the machine default); builds depend on a manual
`flutter config --jdk-dir`.

## Desired Behavior
- `client/android/gradle/gradle-daemon-jvm.properties` with `toolchainVersion=21` (Gradle daemon JVM
  criteria): the daemon runs on an installed JDK 21 even with `JAVA_HOME` on Java 25.
- `.sdkmanrc` with `java=21.0.9-tem` for terminal use.
- The toolchain requirement is documented in `docs/tech/dependencies.md`.

## Out Of Scope
Upgrading Gradle/AGP (post-release).

## Acceptance Criteria
- [x] `./gradlew help` with `JAVA_HOME` on Java 25 succeeds and the daemon runs on JDK 21.
- [x] `flutter build apk --debug --flavor dev` succeeds.

## Verification
As above.

## Documentation Updates
`docs/tech/dependencies.md`, `docs/qa/findings.md`.

## Rollout Notes
None.
