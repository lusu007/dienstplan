# Stable dependency audit — 5 October 2026

## Failed PRs

- [#430](https://github.com/lusu007/dienstplan/pull/430): [CI log](https://github.com/lusu007/dienstplan/actions/runs/34132058066/job/101774239916) fails during `flutter pub get`: Freezed >=4 requires Dart >=3.13, but Flutter 3.44.4 supplies Dart 3.12.2. It also selects Sentry 10 alpha; the latest stable Sentry is 9.30.1.
- [#433](https://github.com/lusu007/dienstplan/pull/433): [CI log](https://github.com/lusu007/dienstplan/actions/runs/36434576797/job/108969055673) fails during `flutter pub get`: file_saver >=0.5 requires meta ^1.19, while the old Flutter SDK pins flutter_test to meta 1.18.

## Stable toolchain

Flutter 3.47.6 / Dart 3.13.5 is the current stable release, verified against the [official release manifest](https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json). All three Flutter workflows use this release. The declared minimum is Flutter >=3.47.0 / Dart >=3.13.0.

Android: AGP 9.4.1, Gradle 9.8.0 and Kotlin 2.4.20 are stable; desugar_jdk_libs 2.1.5 and NDK 28.2.13676358 remain current/compatible. Java 25 remains the configured LTS toolchain. AGP 9.4 requires Gradle >=9.6, which the updated wrapper satisfies.

iOS: use Xcode 26.3, the newest version listed for the existing [macOS 15 runner](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md). This is the newest compatible runner choice, rather than a claim that it is Apple's newest global release. iOS compilation, signing and deployment cannot be verified on Linux.

All workflow action references were checked against official latest releases: checkout v7.0.1, cache v6.1.0, setup-java v6.0.1, flutter-action v2.23.0, release-please v5.0.0, github-labeler v6.0.0, action-gh-release v3.0.3, setup-xcode v1.7.0, upload-google-play v1.1.5, sign-android-release v1, and semantic-pull-request v6.1.1. Existing major-tag references already resolve to these releases; the semantic PR action is already pinned to the latest release SHA.

## Direct package audit

Pub.dev package API `latest` releases and the resolved lockfile were checked for all 32 direct hosted packages. All are latest stable except Freezed, as explained below. SDK packages remain tied to Flutter.

| Package | Previous declared constraint | Resolved stable version |
| --- | --- | --- |
| `sentry_flutter` | `^9.19.0` | `9.30.1` |
| `auto_route` | `^11.1.0` | `11.2.0` |
| `flutter_riverpod` | `^3.3.1` | `3.4.3` |
| `riverpod_annotation` | `^4.0.2` | `4.0.7` |
| `freezed_annotation` | `^3.1.0` | `3.1.0` |
| `sqflite` | `^2.4.3` | `2.4.4` |
| `path` | `^1.9.1` | `1.9.1` |
| `table_calendar` | `^3.2.0` | `3.3.0` |
| `flutter_local_notifications` | `^22.0.1` | `22.3.1` |
| `intl` | `^0.20.2` | `0.20.3` |
| `shared_preferences` | `^2.5.5` | `2.5.5` |
| `path_provider` | `^2.1.5` | `2.1.6` |
| `logger` | `^2.7.0` | `2.8.0` |
| `package_info_plus` | `^10.1.0` | `10.2.2` |
| `url_launcher` | `^6.3.2` | `6.3.3` |
| `share_plus` | `^13.1.0` | `13.3.1` |
| `dio` | `^5.9.2` | `5.11.1` |
| `json_annotation` | `^4.11.0` | `4.12.0` |
| `dart_flutter_version` | `^1.0.37` | `1.0.56` |
| `file_saver` | `^0.4.0` | `0.6.0` |
| `open_file` | `^4.0.0` | `4.0.0` |
| `flutter_markdown_plus` | `^1.0.3` | `1.0.12` |
| `liquid_glass_widgets` | `1.7.2` | `1.9.0` |
| `sentry_dart_plugin` | `^3.3.0` | `3.4.0` |
| `flutter_launcher_icons` | `^0.14.4` | `0.14.4` |
| `flutter_native_splash` | `^2.4.8` | `2.4.8` |
| `build_runner` | `^2.14.1` | `2.16.1` |
| `riverpod_generator` | `^4.0.3` | `4.0.9` |
| `freezed` | `^3.2.5` | `4.0.1` |
| `auto_route_generator` | `">=10.2.4 <10.5.0"` | `10.6.0` |
| `json_serializable` | `">=6.13.0 <6.13.1"` | `6.14.1` |
| `flutter_lints` | `^6.0.0` | `6.0.0` |

## Remaining constraints

- Freezed **4.0.1** is the latest compatible stable version: 4.0.2 requires analyzer 14, while auto_route_generator 10.6.0 requires analyzer <14. Retain the explicit cap until the router generator supports analyzer 14. The previous router/json generator caps tied to old Riverpod are removed.
- Latest stable Sentry **9.30.1** requires jni ^0.14.2. Consequently jni 1.x, path_provider_android 2.3.1 (requires jni 1.x), and package_config 3 (jni 0.14 requires package_config ^2.1) cannot be selected together with stable Sentry. Do not override these requirements. Sentry 10 remains a prerelease.
- source_gen 4.3.0 and analyzer 14 are blocked by the router generator; corresponding analyzer internals remain on the compatible versions.
- cross_file, dbus, cli_util and injector remain within upstream major constraints from share_plus, flutter_local_notifications_linux, flutter_launcher_icons and sentry_dart_plugin, respectively.
- material_color_utilities and test_api remain SDK-pinned.
- Riverpod's stable generator directly requires `riverpod_analyzer_utils: 1.0.0-dev.12`; this transitive prerelease is an upstream requirement of the stable package, not a manually selected prerelease upgrade.

## Reproducibility and migrations

Commit pubspec.lock for this application and enforce it in lint/release installs. Cache Pub dependencies by lockfile. CI now verifies checked-in generated code with build_runner `--only-check` and runs the existing test suite.

Regenerate Freezed/Riverpod/router outputs and localizations; apply Dart 3.13 formatting and initializing-formal lint fixes. The named constructor arguments stay public (`remoteDataSource` / `localDataSource`) using Dart 3.13's private-field initializing formals. file_saver's removed Dio options are not used by the application's saveAs call, so its export API requires no migration.

## Validation

- Flutter pub get --enforce-lockfile: passes.
- build_runner build and build --only-check: pass.
- Localization generation and whole-project format check: pass.
- Flutter analyze --no-pub: no issues.
- Full Flutter suite: **162 tests pass**.
- ARM64 dev debug APK with AGP 9.4.1 / Gradle 9.8.0 / Kotlin 2.4.20: builds successfully.
- git diff --check: passes.

The Android build emits the existing Sentry KGP migration warning. Stable Sentry still applies KGP; the migration is available in the Sentry 10 prerelease series. Keep the stable version and document the warning. Production signing/upload and iOS compilation were not run.
