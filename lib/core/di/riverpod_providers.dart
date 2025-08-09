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

// Repositories (interfaces + implementations)
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/data/repositories/schedule_repository.dart'
    as data_repos;
import 'package:dienstplan/data/repositories/settings_repository.dart'
    as data_repos;
import 'package:dienstplan/data/repositories/config_repository.dart'
    as data_repos;

// Use cases
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/reset_settings_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_configs_use_case.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/load_default_config_use_case.dart';
import 'package:dienstplan/domain/services/schedule_merge_service.dart';
import 'package:dienstplan/domain/policies/date_range_policy.dart';
import 'package:dienstplan/domain/use_cases/ensure_month_schedules_use_case.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;
import 'package:dienstplan/domain/services/config_query_service.dart';

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
@riverpod
Stream<Locale> currentLocale(Ref ref) async* {
  final LanguageService languageService =
      await ref.watch(languageServiceProvider.future);
  final StreamController<Locale> controller =
      StreamController<Locale>.broadcast();
  controller.add(languageService.currentLocale);
  void emit() => controller.add(languageService.currentLocale);
  languageService.addListener(emit);
  ref.onDispose(() {
    languageService.removeListener(emit);
    controller.close();
  });
  yield* controller.stream;
}

@riverpod
Future<ThemeMode> themeMode(Ref ref) async {
  final GetSettingsUseCase getSettings =
      await ref.watch(getSettingsUseCaseProvider.future);
  final domain.Settings? settings = await getSettings.execute();
  switch (settings?.themePreference) {
    case domain.ThemePreference.light:
      return ThemeMode.light;
    case domain.ThemePreference.dark:
      // Temporary override: dark not implemented -> use light for now
      return ThemeMode.light;
    case domain.ThemePreference.system:
    case null:
      // Temporary override: system not implemented -> use light for now
      return ThemeMode.light;
  }
}

@riverpod
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

@riverpod
ShareService shareService(Ref ref) {
  return ShareService();
}

// Data sources
@riverpod
Future<ScheduleLocalDataSource> scheduleLocalDataSource(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return ScheduleLocalDataSource(db);
}

@riverpod
Future<SettingsLocalDataSource> settingsLocalDataSource(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SettingsLocalDataSource(db);
}

@riverpod
Future<ConfigLocalDataSource> configLocalDataSource(Ref ref) async {
  final ScheduleConfigService cfg =
      await ref.watch(scheduleConfigServiceProvider.future);
  return ConfigLocalDataSource(cfg);
}

// Repositories
@riverpod
Future<ScheduleRepository> scheduleRepository(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return data_repos.ScheduleRepositoryImpl(db);
}

@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return data_repos.SettingsRepositoryImpl(db);
}

@riverpod
Future<ConfigRepository> configRepository(Ref ref) async {
  final ScheduleConfigService cfg =
      await ref.watch(scheduleConfigServiceProvider.future);
  return data_repos.ConfigRepositoryImpl(cfg);
}

// Use cases
@riverpod
Future<GetSchedulesUseCase> getSchedulesUseCase(Ref ref) async {
  final ScheduleRepository repo =
      await ref.watch(scheduleRepositoryProvider.future);
  return GetSchedulesUseCase(repo);
}

@riverpod
Future<GenerateSchedulesUseCase> generateSchedulesUseCase(Ref ref) async {
  final ScheduleRepository scheduleRepo =
      await ref.watch(scheduleRepositoryProvider.future);
  final ConfigRepository configRepo =
      await ref.watch(configRepositoryProvider.future);
  return GenerateSchedulesUseCase(scheduleRepo, configRepo);
}

@riverpod
Future<GetSettingsUseCase> getSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return GetSettingsUseCase(repo);
}

@riverpod
Future<SaveSettingsUseCase> saveSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return SaveSettingsUseCase(repo);
}

@riverpod
Future<ResetSettingsUseCase> resetSettingsUseCase(Ref ref) async {
  final SettingsRepository repo =
      await ref.watch(settingsRepositoryProvider.future);
  return ResetSettingsUseCase(repo);
}

@riverpod
Future<GetConfigsUseCase> getConfigsUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return GetConfigsUseCase(repo);
}

@riverpod
Future<SetActiveConfigUseCase> setActiveConfigUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return SetActiveConfigUseCase(repo);
}

@riverpod
Future<LoadDefaultConfigUseCase> loadDefaultConfigUseCase(Ref ref) async {
  final ConfigRepository repo =
      await ref.watch(configRepositoryProvider.future);
  return LoadDefaultConfigUseCase(repo);
}

// Utilities / Services
@riverpod
ScheduleMergeService scheduleMergeService(Ref ref) {
  return ScheduleMergeService();
}

@riverpod
DateRangePolicy dateRangePolicy(Ref ref) {
  return const PlusMinusMonthsPolicy(monthsBefore: 3, monthsAfter: 3);
}

@riverpod
ConfigQueryService configQueryService(Ref ref) {
  return const ConfigQueryService();
}

// Use cases (additional)
@riverpod
Future<EnsureMonthSchedulesUseCase> ensureMonthSchedulesUseCase(Ref ref) async {
  final GetSchedulesUseCase get =
      await ref.watch(getSchedulesUseCaseProvider.future);
  final GenerateSchedulesUseCase gen =
      await ref.watch(generateSchedulesUseCaseProvider.future);
  return EnsureMonthSchedulesUseCase(get, gen);
}
