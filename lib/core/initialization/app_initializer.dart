import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:flutter/scheduler.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';

class AppInitializer {
  static bool _sentryInitialized = false;
  static Future<ProviderContainer> initialize() async {
    SentryWidgetsFlutterBinding.ensureInitialized();

    // Initialize logger first
    await AppLogger.initialize();
    AppLogger.i('Starting Dienstplan application');

    // Create ProviderContainer to pre-warm services during bootstrap
    final container = ProviderContainer();
    // Attach container to logger so logging can access providers without new containers
    AppLogger.setProviderContainer(container);
    // Warm critical services
    await container.read(sentryServiceProvider.future);
    await container.read(languageServiceProvider.future);
    // Pre-warm settings to avoid theme flash on startup
    await container.read(settingsProvider.future);
    // Conditionally pre-warm school holidays using domain settings
    final GetSettingsUseCase getSettingsUseCase = await container.read(
      getSettingsUseCaseProvider.future,
    );
    final settings = await getSettingsUseCase.execute();
    if (settings?.showSchoolHolidays == true &&
        settings?.schoolHolidayStateCode != null &&
        settings!.schoolHolidayStateCode!.isNotEmpty) {
      await container.read(schoolHolidaysProvider.future);
    }

    // Initialize heavy tasks after first frame to avoid jank
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        AppLogger.i('Initializing schedule generation isolate');
        await ScheduleGenerationIsolate.initialize();
        AppLogger.i('Schedule generation isolate initialized');
        // Warm up database lazily
        await container.read(databaseServiceProvider.future);
      } catch (e, stackTrace) {
        AppLogger.e('Error during post-frame initialization', e, stackTrace);
      }
    });

    return container;
  }

  static Future<void> initializeSentry(SentryService sentryService) async {
    if (_sentryInitialized) {
      return;
    }
    await SentryFlutter.init((SentryFlutterOptions options) {
      options.dsn = SentryConfig.dsn;
      SentryConfig.configureOptions(options, sentryService);
    });
    _sentryInitialized = true;
  }
}
