# Sentry Telemetry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add privacy-first Sentry breadcrumbs and traces that improve issue debugging without sending noisy or sensitive data.

**Architecture:** Add one `SentryTelemetry` helper as the only new app-facing Sentry instrumentation API. Configure SDK hooks to drop disabled telemetry and sanitize breadcrumbs/logs before upload, then use the helper at a few high-value app operations.

**Tech Stack:** Flutter, Dart, `sentry_flutter` 9.16.0, `flutter_test`.

---

### Task 1: Telemetry Boundary

**Files:**
- Create: `lib/core/telemetry/sentry_telemetry.dart`
- Test: `test/core/sentry_telemetry_test.dart`

- [x] **Step 1: Write failing tests**

Validate that sensitive breadcrumb data is removed, long values are bounded, disabled uploads drop breadcrumbs, and release debug logs are filtered.

- [x] **Step 2: Run tests to verify failure**

Run: `flutter test test/core/sentry_telemetry_test.dart`
Expected: fail because `SentryTelemetry` does not exist yet.

- [x] **Step 3: Implement minimal telemetry helper**

Create a helper with `recordBreadcrumb`, `traceOperation`, `beforeBreadcrumb`, and `beforeSendLog`.

- [x] **Step 4: Run tests to verify pass**

Run: `flutter test test/core/sentry_telemetry_test.dart`
Expected: pass.

### Task 2: SDK Hook Integration

**Files:**
- Modify: `lib/core/config/sentry_config.dart`
- Test: `test/core/sentry_config_test.dart`

- [x] **Step 1: Write failing tests**

Validate `configureOptions` wires `beforeBreadcrumb` and filters logs through `SentryTelemetry`.

- [x] **Step 2: Implement hook wiring**

Use `SentryTelemetry.beforeBreadcrumb` and `SentryTelemetry.beforeSendLog` from `SentryConfig`.

- [x] **Step 3: Run focused tests**

Run: `flutter test test/core/sentry_config_test.dart test/core/sentry_telemetry_test.dart`
Expected: pass.

### Task 3: High-Value Breadcrumbs And Spans

**Files:**
- Modify: `lib/core/initialization/app_initializer.dart`
- Modify: `lib/domain/use_cases/generate_schedules_use_case.dart`
- Modify: `lib/domain/use_cases/generate_calendar_export_use_case.dart`
- Modify: `lib/presentation/screens/contact_feedback_screen.dart`

- [x] **Step 1: Instrument only meaningful outcomes**

Add breadcrumbs for setup/post-frame initialization, schedule generation outcomes, calendar export outcomes, and feedback outcomes.

- [x] **Step 2: Add manual spans**

Wrap post-frame initialization, schedule generation, and calendar export in `traceOperation`.

- [x] **Step 3: Verify**

Run: `flutter analyze`, `flutter test`, and the required Android Gradle checks from `android/`.
