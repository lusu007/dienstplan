import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('SentryConfig.configureOptions', () {
    test('uses privacy-first defaults for optional telemetry', () {
      final SentryFlutterOptions options = SentryFlutterOptions();
      SentryConfig.configureOptions(
        options,
        SentryService(),
        PackageInfo(
          appName: 'Dienstplan',
          packageName: 'io.scelus.dienstplan.dev',
          version: '1.2.3',
          buildNumber: '45',
        ),
      );

      expect(options.sendDefaultPii, false);
      expect(options.enableUserInteractionTracing, false);
      expect(options.enableUserInteractionBreadcrumbs, true);
    });

    test(
      'enables explicit feedback screenshot capture without auto screenshots',
      () {
        final SentryFlutterOptions options = SentryFlutterOptions();
        SentryConfig.configureOptions(
          options,
          SentryService(),
          PackageInfo(
            appName: 'Dienstplan',
            packageName: 'io.scelus.dienstplan.dev',
            version: '1.2.3',
            buildNumber: '45',
          ),
        );

        expect(options.attachScreenshot, true);
        expect(options.beforeCaptureScreenshot, isNotNull);
        expect(
          options.beforeCaptureScreenshot!(SentryEvent(), Hint(), false),
          false,
        );
      },
    );

    test('wires beforeBreadcrumb through telemetry sanitizer', () {
      final SentryFlutterOptions options = SentryFlutterOptions();
      SentryConfig.configureOptions(
        options,
        SentryService(),
        PackageInfo(
          appName: 'Dienstplan',
          packageName: 'io.scelus.dienstplan.dev',
          version: '1.2.3',
          buildNumber: '45',
        ),
      );

      final Breadcrumb? result = options.beforeBreadcrumb!(
        Breadcrumb(
          category: 'feedback',
          message: 'Contact feedback submitted',
          data: <String, dynamic>{
            'feedbackId': 'abc123',
            'email': 'person@example.com',
          },
        ),
        Hint(),
      );

      expect(result, isNotNull);
      expect(result!.data, containsPair('feedbackId', 'abc123'));
      expect(result.data, isNot(contains('email')));
    });

    test('wires beforeSendLog through telemetry filter', () async {
      final SentryFlutterOptions options = SentryFlutterOptions();
      SentryConfig.configureOptions(
        options,
        SentryService(),
        PackageInfo(
          appName: 'Dienstplan',
          packageName: 'io.scelus.dienstplan.dev',
          version: '1.2.3',
          buildNumber: '45',
        ),
      );

      final SentryLog? result = await options.beforeSendLog!(
        SentryLog(
          timestamp: DateTime.utc(2026, 4, 27),
          level: SentryLogLevel.info,
          body: 'Remote response data received (responseData={raw})',
          attributes: const <String, SentryAttribute>{},
        ),
      );

      expect(result, isNull);
    });
  });
}
