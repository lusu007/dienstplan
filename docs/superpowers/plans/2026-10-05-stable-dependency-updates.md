# Stable Dependency Updates Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task by task.

**Goal:** Resolve dependency PRs #430 and #433 and upgrade all direct dependencies to compatible stable releases.

**Architecture:** Align lint and release workflows on Flutter 3.47.6 / Dart 3.13.5, update pub constraints and lockfile together, and regenerate checked-in code. Preserve existing application behavior and verify platform compatibility.

**Tech Stack:** Flutter, Dart, Pub, Gradle, GitHub Actions.

**Spec:** User request in this chat: investigate both failing dependency PRs, use newest stable versions where possible, audit all other dependencies.

## Global Constraints

- Use stable SDK and direct package releases; Sentry 10 prereleases are excluded.
- Preserve unrelated UI changes from main.
- Do not merge or close existing PRs automatically.

## Review Focus

- File export API changes must preserve schedule export.
- Freezed/Riverpod/router generation must remain reproducible.
- Localization and calendar versions must agree with Flutter SDK pins.
- Android plugins must compile with the existing Gradle setup.
- iOS release toolchain requirements must be documented if they cannot be verified on Linux.

### Task 1: SDK and dependency resolution

- [x] Read failure logs: #430 fails because Freezed 4 requires Dart >=3.13; #433 fails because file_saver >=0.5 requires meta ^1.19 while Flutter 3.44 pins meta 1.18.
- [x] Audit pub.dev stable releases and GitHub Actions releases.
- [x] Update pubspec.yaml and all Flutter CI pins.
- [x] Resolve and upgrade pubspec.lock with Flutter 3.47.6.

### Task 2: Compatibility and generated code

- [x] Run code generation and analysis; reproduce API incompatibilities before fixing.
- [x] Apply necessary migrations and format source/generated code.
- [x] Run the existing test suite and Android build.

### Task 3: Review and delivery

- [x] Recheck outdated dependencies and document any SDK or transitive constraints.
- [x] Review the diff and verification evidence.
- [ ] Commit and open a reviewable dependency PR covering both existing updates.
