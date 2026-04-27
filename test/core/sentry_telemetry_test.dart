import 'package:dienstplan/core/telemetry/sentry_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('SentryTelemetry.beforeBreadcrumb', () {
    test('drops breadcrumbs when uploads are disabled', () {
      final breadcrumb = Breadcrumb(
        category: 'schedule',
        message: 'Schedule generation completed',
      );

      final result = SentryTelemetry.beforeBreadcrumb(
        breadcrumb,
        Hint(),
        uploadsAllowed: false,
      );

      expect(result, isNull);
    });

    test('sanitizes sensitive data and bounds string values', () {
      final breadcrumb = Breadcrumb(
        category: 'feedback',
        message: 'Contact feedback submitted',
        data: <String, dynamic>{
          'feedbackId': 'abc123',
          'email': 'person@example.com',
          'message': 'raw user message',
          'entryCount': 42,
          'longValue': 'x' * 240,
          'nested': <String, String>{'unsafe': 'object'},
        },
      );

      final result = SentryTelemetry.beforeBreadcrumb(
        breadcrumb,
        Hint(),
        uploadsAllowed: true,
      );

      expect(result, isNotNull);
      expect(result!.data, containsPair('feedbackId', 'abc123'));
      expect(result.data, containsPair('entryCount', 42));
      expect(result.data, isNot(contains('email')));
      expect(result.data, isNot(contains('message')));
      expect(result.data, isNot(contains('nested')));
      expect(result.data!['longValue'], hasLength(160));
    });
  });

  group('SentryTelemetry.beforeSendLog', () {
    test('drops logs when uploads are disabled', () {
      final log = SentryLog(
        timestamp: DateTime.utc(2026, 4, 27),
        level: SentryLogLevel.info,
        body: 'Application started (screen=main)',
        attributes: const <String, SentryAttribute>{},
      );

      final result = SentryTelemetry.beforeSendLog(
        log,
        uploadsAllowed: false,
        isRelease: false,
      );

      expect(result, isNull);
    });

    test('drops debug logs in release mode', () {
      final log = SentryLog(
        timestamp: DateTime.utc(2026, 4, 27),
        level: SentryLogLevel.debug,
        body: 'Cache lookup completed (cacheHit=true)',
        attributes: const <String, SentryAttribute>{},
      );

      final result = SentryTelemetry.beforeSendLog(
        log,
        uploadsAllowed: true,
        isRelease: true,
      );

      expect(result, isNull);
    });

    test('drops logs that likely contain raw payloads', () {
      final log = SentryLog(
        timestamp: DateTime.utc(2026, 4, 27),
        level: SentryLogLevel.info,
        body: 'Remote response data received (responseData={raw})',
        attributes: const <String, SentryAttribute>{},
      );

      final result = SentryTelemetry.beforeSendLog(
        log,
        uploadsAllowed: true,
        isRelease: false,
      );

      expect(result, isNull);
    });
  });
}
