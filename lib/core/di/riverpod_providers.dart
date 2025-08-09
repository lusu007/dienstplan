import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/data/services/share_service.dart';

// Data sources
import 'package:dienstplan/data/data_sources/schedule_local_data_source.dart';
import 'package:dienstplan/data/data_sources/settings_local_data_source.dart';
import 'package:dienstplan/data/data_sources/config_local_data_source.dart';

// Repositories
import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/data/repositories/settings_repository.dart';
import 'package:dienstplan/data/repositories/config_repository.dart';

// Use cases
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/load_default_config_use_case.dart';

part 'riverpod_providers.g.dart';

// Services
@Riverpod(keepAlive: true)
Future<DatabaseService> databaseService(Ref ref) async {
  final DatabaseService service = DatabaseService();
  await service.init();
  return service;
}

@Riverpod(keepAlive: true)
Future<ScheduleConfigService> scheduleConfigService(Ref ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ScheduleConfigService service = ScheduleConfigService(prefs);
  await service.initialize();
  return service;
}

@Riverpod(keepAlive: true)
Future<LanguageService> languageService(Ref ref) async {
  final LanguageService service = LanguageService();
  await service.initialize();
  return service;
}

// UI/Locale/Theme providers
@Riverpod(keepAlive: true)
Stream<Locale> currentLocale(Ref ref) async* {
  final LanguageService languageService =
      await ref.watch(languageServiceProvider.future);
  final StreamController<Locale> controller = StreamController<Locale>();
  void emit() => controller.add(languageService.currentLocale);
  controller.add(languageService.currentLocale);
  languageService.addListener(emit);
  ref.onDispose(() {
    languageService.removeListener(emit);
    controller.close();
  });
  yield* controller.stream;
}

@Riverpod(keepAlive: true)
ThemeMode themeMode(Ref ref) {
  // TODO: read persisted theme setting when available
  return ThemeMode.system;
}

@Riverpod(keepAlive: true)
ThemeData appTheme(Ref ref) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF005B8C),
      primary: const Color(0xFF005B8C),
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF005B8C),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}

@Riverpod(keepAlive: true)
Future<SentryService> sentryService(Ref ref) async {
  final SentryService service = SentryService();
  await service.initialize();
  return service;
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) {
  return ShareService();
}

// Data sources
@Riverpod(keepAlive: true)
Future<ScheduleLocalDataSource> scheduleLocalDataSource(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return ScheduleLocalDataSource(db);
}

@Riverpod(keepAlive: true)
Future<SettingsLocalDataSource> settingsLocalDataSource(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SettingsLocalDataSource(db);
}

@Riverpod(keepAlive: true)
Future<ConfigLocalDataSource> configLocalDataSource(Ref ref) async {
  final ScheduleConfigService cfg =
      await ref.watch(scheduleConfigServiceProvider.future);
  return ConfigLocalDataSource(cfg);
}

// Repositories
@Riverpod(keepAlive: true)
Future<ScheduleRepository> scheduleRepository(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return ScheduleRepository(db);
}

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SettingsRepository(db);
}

@Riverpod(keepAlive: true)
Future<ConfigRepository> configRepository(Ref ref) async {
  final ScheduleConfigService cfg =
      await ref.watch(scheduleConfigServiceProvider.future);
  return ConfigRepository(cfg);
}

// Use cases
@Riverpod(keepAlive: true)
Future<GetSchedulesUseCase> getSchedulesUseCase(Ref ref) async {
  final ScheduleRepository repo =
      await ref.watch(scheduleRepositoryProvider.future);
  return GetSchedulesUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<GenerateSchedulesUseCase> generateSchedulesUseCase(Ref ref) async {
  final ScheduleRepository scheduleRepo =
      await ref.watch(scheduleRepositoryProvider.future);
  final ConfigRepository configRepo =
      await ref.watch(configRepositoryProvider.future);
  return GenerateSchedulesUseCase(scheduleRepo, configRepo);
}

@Riverpod(keepAlive: true)
Future<GetSettingsUseCase> getSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return GetSettingsUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<SaveSettingsUseCase> saveSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return SaveSettingsUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<ResetSettingsUseCase> resetSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return ResetSettingsUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<GetConfigsUseCase> getConfigsUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return GetConfigsUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<SetActiveConfigUseCase> setActiveConfigUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return SetActiveConfigUseCase(repo);
}

@Riverpod(keepAlive: true)
Future<LoadDefaultConfigUseCase> loadDefaultConfigUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return LoadDefaultConfigUseCase(repo);
}
