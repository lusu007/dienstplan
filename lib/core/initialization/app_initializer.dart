import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

class AppInitializer {
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

    // Initialize schedule generation isolate
    AppLogger.i('Initializing schedule generation isolate');
    await ScheduleGenerationIsolate.initialize();
    AppLogger.i('Schedule generation isolate initialized');

    return container;
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
