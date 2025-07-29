import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/di/injection_container.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/config/sentry_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize dependency injection
    await InjectionContainer.init();

    // Initialize logger first
    await AppLogger.initialize();
    AppLogger.i('Starting Dienstplan application');

    // Set up migration dialog callback
    DatabaseService.setMigrationDialogCallback(_showMigrationDialog);

    // Get services from DI container and ensure they're initialized
    // ignore: unused_local_variable
    final sentryService = await GetIt.instance.getAsync<SentryService>();
    // ignore: unused_local_variable
    final languageService = await GetIt.instance.getAsync<LanguageService>();
  }

  static void _showMigrationDialog(String message) {
    // This will be called from the database service during migration
    // The actual dialog will be shown by the UI layer
    AppLogger.i('Migration dialog should be shown: $message');
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
