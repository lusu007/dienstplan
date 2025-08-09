import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/di/injection_container.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';

class AppInitializer {
  static Future<void> initialize() async {
    SentryWidgetsFlutterBinding.ensureInitialized();

    // Initialize dependency injection
    await InjectionContainer.init();

    // Initialize logger first
    await AppLogger.initialize();
    AppLogger.i('Starting Dienstplan application');

    // Get services from DI container and ensure they're initialized
    // ignore: unused_local_variable
    final sentryService = await GetIt.instance.getAsync<SentryService>();
    // ignore: unused_local_variable
    final languageService = await GetIt.instance.getAsync<LanguageService>();

    // Initialize schedule generation isolate
    AppLogger.i('Initializing schedule generation isolate');
    await ScheduleGenerationIsolate.initialize();
    AppLogger.i('Schedule generation isolate initialized');
  }

  static Future<void> initializeSentry(SentryService sentryService) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = SentryConfig.dsn;
        SentryConfig.configureOptions(options, sentryService);
      },
    );
  }
}
