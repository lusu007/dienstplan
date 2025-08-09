import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data Sources
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/data/services/share_service.dart';
import 'package:dienstplan/data/data_sources/schedule_local_data_source.dart';
import 'package:dienstplan/data/data_sources/settings_local_data_source.dart';
import 'package:dienstplan/data/data_sources/config_local_data_source.dart';

// Repositories
import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/data/repositories/settings_repository.dart';
import 'package:dienstplan/data/repositories/config_repository.dart';

// Use Cases
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/load_default_config_use_case.dart';

import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';

final GetIt getIt = GetIt.instance;

class InjectionContainer {
  static Future<void> init() async {
    AppLogger.i('InjectionContainer: Initializing dependency injection');

    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Register Services as Singletons
      await _registerServices(prefs);

      // Register Data Sources as Singletons
      _registerDataSources();

      // Register Repositories as Singletons
      _registerRepositories();

      // Register Use Cases as Factories
      _registerUseCases();

      // Note: Controllers are no longer needed - state is managed via Riverpod providers

      AppLogger.i(
          'InjectionContainer: Dependency injection initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e('InjectionContainer: Error initializing dependency injection',
          e, stackTrace);
      rethrow;
    }
  }

  static Future<void> _registerServices(SharedPreferences prefs) async {
    AppLogger.d('InjectionContainer: Registering services');

    // DatabaseService - Singleton
    getIt.registerLazySingletonAsync<DatabaseService>(() async {
      final service = DatabaseService();
      await service.init();
      return service;
    });

    // ScheduleConfigService - Singleton
    getIt.registerLazySingletonAsync<ScheduleConfigService>(() async {
      final service = ScheduleConfigService(prefs);
      await service.initialize();
      return service;
    });

    // LanguageService - Singleton
    getIt.registerLazySingletonAsync<LanguageService>(() async {
      final service = LanguageService();
      await service.initialize();
      return service;
    });

    // SentryService - Singleton
    getIt.registerLazySingletonAsync<SentryService>(() async {
      final service = SentryService();
      await service.initialize();
      return service;
    });

    // ShareService - Singleton
    getIt.registerLazySingleton<ShareService>(() => ShareService());
  }

  static void _registerDataSources() {
    AppLogger.d('InjectionContainer: Registering data sources');

    // ScheduleLocalDataSource - Singleton
    getIt.registerLazySingletonAsync<ScheduleLocalDataSource>(() async {
      final databaseService = await getIt.getAsync<DatabaseService>();
      return ScheduleLocalDataSource(databaseService);
    });

    // SettingsLocalDataSource - Singleton
    getIt.registerLazySingletonAsync<SettingsLocalDataSource>(() async {
      final databaseService = await getIt.getAsync<DatabaseService>();
      return SettingsLocalDataSource(databaseService);
    });

    // ConfigLocalDataSource - Singleton
    getIt.registerLazySingletonAsync<ConfigLocalDataSource>(() async {
      final configService = await getIt.getAsync<ScheduleConfigService>();
      return ConfigLocalDataSource(configService);
    });
  }

  static void _registerRepositories() {
    AppLogger.d('InjectionContainer: Registering repositories');

    // ScheduleRepository - Singleton
    getIt.registerLazySingletonAsync<ScheduleRepository>(() async {
      final databaseService = await getIt.getAsync<DatabaseService>();
      return ScheduleRepository(databaseService);
    });

    // SettingsRepository - Singleton
    getIt.registerLazySingletonAsync<SettingsRepository>(() async {
      final databaseService = await getIt.getAsync<DatabaseService>();
      return SettingsRepository(databaseService);
    });

    // ConfigRepository - Singleton
    getIt.registerLazySingletonAsync<ConfigRepository>(() async {
      final configService = await getIt.getAsync<ScheduleConfigService>();
      return ConfigRepository(configService);
    });
  }

  static void _registerUseCases() {
    AppLogger.d('InjectionContainer: Registering use cases');

    // Schedule Use Cases - Factories
    getIt.registerFactoryAsync<GetSchedulesUseCase>(() async {
      final repository = await getIt.getAsync<ScheduleRepository>();
      return GetSchedulesUseCase(repository);
    });

    getIt.registerFactoryAsync<GenerateSchedulesUseCase>(() async {
      final scheduleRepository = await getIt.getAsync<ScheduleRepository>();
      final configRepository = await getIt.getAsync<ConfigRepository>();
      return GenerateSchedulesUseCase(scheduleRepository, configRepository);
    });

    // Settings Use Cases - Factories
    getIt.registerFactoryAsync<GetSettingsUseCase>(() async {
      final repository = await getIt.getAsync<SettingsRepository>();
      return GetSettingsUseCase(repository);
    });

    getIt.registerFactoryAsync<SaveSettingsUseCase>(() async {
      final repository = await getIt.getAsync<SettingsRepository>();
      return SaveSettingsUseCase(repository);
    });

    getIt.registerFactoryAsync<ResetSettingsUseCase>(() async {
      final repository = await getIt.getAsync<SettingsRepository>();
      return ResetSettingsUseCase(repository);
    });

    // Config Use Cases - Factories
    getIt.registerFactoryAsync<GetConfigsUseCase>(() async {
      final repository = await getIt.getAsync<ConfigRepository>();
      return GetConfigsUseCase(repository);
    });

    getIt.registerFactoryAsync<SetActiveConfigUseCase>(() async {
      final repository = await getIt.getAsync<ConfigRepository>();
      return SetActiveConfigUseCase(repository);
    });

    getIt.registerFactoryAsync<LoadDefaultConfigUseCase>(() async {
      final repository = await getIt.getAsync<ConfigRepository>();
      return LoadDefaultConfigUseCase(repository);
    });
  }

  static Future<void> reset() async {
    AppLogger.i('InjectionContainer: Resetting dependency injection');
    await getIt.reset();
  }

  static Future<void> dispose() async {
    AppLogger.i('InjectionContainer: Disposing dependency injection');

    // Clear settings cache
    SettingsCache.clearCache();

    await getIt.reset();
  }
}
