# Liquid Glass Migration Implementation Plan

**Goal:** Standardize the existing glass UI on liquid_glass_widgets while preserving app workflows.

**Architecture:** Keep the app's shared component interfaces as adapters. The package owns glass rendering and app-wide glass theming. Calendar cells and schedule content remain lightweight. Preserve routing, dimensions, localization, data/state, and action behavior. User authorized implementation following the adapter proposal; performance tuning and further UX changes are deferred.

**Tech Stack:** Flutter 3.44.4, Riverpod, liquid_glass_widgets 1.7.2.

## Constraints
- Do not modify the two pre-existing untracked performance plans.
- Preserve light/dark app theme selection independent of OS brightness.
- Preserve disabled/selected controls, sheet scroll behavior, dismiss results, and safe areas.
- Do not introduce premium effects for calendar cells or list rows.
- Work in the current checkout; no competing implementation or tracked changes were present.

## Tasks
- [x] Add pinned package dependency; inspect actual installed public APIs and establish test baseline.
- [x] Add centralized theme/bootstrap integration and package-backed surface adapters; test app brightness and surface composition.
- [x] Migrate shared controls and modal presentation without changing workflows; adapt obsolete rendering assertions and retain interaction tests.
- [x] Run formatter, static analysis, full Flutter tests and Android build where available.
- [x] Review full migration and update style-guide integration instructions.

## Review focus
- Forced app light/dark theme versus opposite OS brightness.
- Active, disabled, destructive and tinted surfaces remain distinguishable.
- Nested controls inside modal glass do not install independent refractive layers.
- Sheet keyboard insets, scroll constraints, route dismissal and navigator context stay intact.
- Tests validate behavior rather than the previous BackdropFilter implementation.

## Verification ledger
- Baseline: 76 tests passed after dependency installation, before implementation.
- Migration RED: four integration tests failed on the original renderer; GREEN after adapter implementation.
- App theme, nested modal material, controls and accessibility integration passed; full pre-review suite: 84 tests, analyzer clean.
- Independent review: two P2 findings, missing standard-renderer button outlines and duplicate disabled dimming. Both reproduced by failing regression tests and fixed centrally. Targeted follow-up: 10 tests passed.
- Review found no further sizing, theme, nesting or modal behavior regressions. On-device visual assessment and performance profiling remain a separate follow-up as requested.

- Final verification: 85/85 Flutter tests passed; `flutter analyze --no-pub` reports no issues; `git diff --check` passed; `flutter build apk --debug --flavor dev --no-pub` succeeded. APK: `build/app/outputs/flutter-apk/app-dev-debug.apk`. The Android build emits existing-plugin KGP compatibility warnings for `file_saver` and `sentry_flutter`; build succeeds.
