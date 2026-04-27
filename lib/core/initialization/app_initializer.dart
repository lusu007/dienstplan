import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/telemetry/sentry_telemetry.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_split_layout_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:flutter/scheduler.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;

class AppInitializer {
  static bool _sentryInitialized = false;
  static Future<ProviderContainer> initialize() async {
    SentryWidgetsFlutterBinding.ensureInitialized();

    // Initialize logger first
    await AppLogger.initialize();
    AppLogger.i('Starting Dienstplan application');

    // Create ProviderContainer to pre-warm services during bootstrap
    final container = ProviderContainer();
    // Warm critical services
    await container.read(sentryServiceProvider.future);
    await container.read(languageServiceProvider.future);
    await container
        .read(calendarSplitLayoutProvider.notifier)
        .hydrateFromPrefs();
    // Pre-warm settings to avoid theme flash on startup
    await container.read(settingsProvider.future);
    // Conditionally pre-warm school holidays using domain settings
    final GetSettingsUseCase getSettingsUseCase = await container.read(
      getSettingsUseCaseProvider.future,
    );
    final settingsResult = await getSettingsUseCase.execute();
    final domain.Settings? settings = settingsResult.isFailure
        ? null
        : settingsResult.valueIfSuccess;
    if (settings?.showSchoolHolidays == true &&
        settings?.schoolHolidayStateCode != null &&
        settings!.schoolHolidayStateCode!.isNotEmpty) {
      await container.read(schoolHolidaysProvider.future);
    }

    // Initialize heavy tasks after first frame to avoid jank
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await SentryTelemetry.traceOperation<void>(
          name: 'app.post_frame_initialization',
          operation: 'app.init',
          data: const <String, dynamic>{'phase': 'post_frame'},
          run: (_) async {
            await ScheduleGenerationIsolate.initialize();
            AppLogger.i(
              'Schedule generation isolate initialized (phase=post_frame)',
            );
            await SentryTelemetry.recordBreadcrumb(
              category: 'app.lifecycle',
              message: 'Schedule generation isolate initialized',
              data: const <String, dynamic>{'phase': 'post_frame'},
            );
            // Warm up database lazily
            await container.read(databaseServiceProvider.future);
            await SentryTelemetry.recordBreadcrumb(
              category: 'app.lifecycle',
              message: 'Database pre-warm completed',
              data: const <String, dynamic>{'phase': 'post_frame'},
            );
            // Start schedule coordinator so calendar/settings get data without waiting for a tap.
            unawaited(() async {
              try {
                await SentryTelemetry.traceOperation<void>(
                  name: 'app.schedule_coordinator_prewarm',
                  operation: 'app.init',
                  data: const <String, dynamic>{'phase': 'post_frame'},
                  run: (_) async {
                    await container.read(scheduleCoordinatorProvider.future);
                  },
                );
                await SentryTelemetry.recordBreadcrumb(
                  category: 'app.lifecycle',
                  message: 'Schedule coordinator pre-warm completed',
                  data: const <String, dynamic>{'phase': 'post_frame'},
                );
              } catch (e, st) {
                await SentryTelemetry.recordBreadcrumb(
                  category: 'app.lifecycle',
                  message: 'Schedule coordinator pre-warm failed',
                  data: <String, dynamic>{
                    'errorType': e.runtimeType.toString(),
                  },
                  level: SentryLevel.warning,
                );
                AppLogger.e(
                  'Schedule coordinator pre-warm failed '
                  '(phase=post_frame, errorType=${e.runtimeType})',
                  e,
                  st,
                );
              }
            }());
          },
        );
        await SentryTelemetry.recordBreadcrumb(
          category: 'app.lifecycle',
          message: 'Post-frame initialization completed',
          data: const <String, dynamic>{'phase': 'post_frame'},
        );
      } catch (e, stackTrace) {
        await SentryTelemetry.recordBreadcrumb(
          category: 'app.lifecycle',
          message: 'Post-frame initialization failed',
          data: <String, dynamic>{'errorType': e.runtimeType.toString()},
          level: SentryLevel.error,
        );
        AppLogger.e(
          'Post-frame initialization failed '
          '(phase=post_frame, errorType=${e.runtimeType})',
          e,
          stackTrace,
        );
      }
    });

    return container;
  }

  static Future<void> initializeSentry(
    SentryService sentryService,
    PackageInfo packageInfo,
  ) async {
    if (_sentryInitialized) {
      return;
    }
    await SentryFlutter.init((SentryFlutterOptions options) {
      SentryConfig.configureOptions(options, sentryService, packageInfo);
    });
    _sentryInitialized = true;
    await sentryService.syncSdkDynamicOptionsAfterInit();
  }
}
