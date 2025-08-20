import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;
import 'package:dienstplan/core/constants/app_colors.dart';

// Services
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/data/services/share_service.dart';

// DAOs
import 'package:dienstplan/data/daos/schedules_dao.dart';
import 'package:dienstplan/data/daos/settings_dao.dart';
import 'package:dienstplan/data/daos/duty_types_dao.dart';
import 'package:dienstplan/data/daos/maintenance_dao.dart';
import 'package:dienstplan/data/daos/schedules_admin_dao.dart';
import 'package:dienstplan/data/daos/schedule_configs_dao.dart';

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
import 'package:dienstplan/domain/services/config_query_service.dart';

part 'riverpod_providers.g.dart';

// Services
@Riverpod(keepAlive: true)
Future<DatabaseService> databaseService(Ref ref) async {
  final DatabaseService service = DatabaseService();
  await service.init();
  return service;
}

// Low-level DAOs built on top of DatabaseService
@riverpod
Future<SchedulesDao> schedulesDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SchedulesDao(db);
}

@riverpod
Future<SettingsDao> settingsDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SettingsDao(db);
}

@riverpod
Future<DutyTypesDao> dutyTypesDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return DutyTypesDao(db);
}

@riverpod
Future<MaintenanceDao> maintenanceDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return MaintenanceDao(db);
}

@riverpod
Future<SchedulesAdminDao> schedulesAdminDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return SchedulesAdminDao(db);
}

@riverpod
Future<ScheduleConfigsDao> scheduleConfigsDao(Ref ref) async {
  final DatabaseService db = await ref.watch(databaseServiceProvider.future);
  return ScheduleConfigsDao(db);
}

@Riverpod(keepAlive: true)
Future<ScheduleConfigService> scheduleConfigService(Ref ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ScheduleConfigsDao dao =
      await ref.watch(scheduleConfigsDaoProvider.future);
  final ScheduleConfigService service = ScheduleConfigService(prefs, dao);
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
      return ThemeMode.dark;
    case domain.ThemePreference.system:
      return ThemeMode.system;
    case null:
      // Default to light theme on first start
      return ThemeMode.light;
  }
}

@riverpod
ThemeData appTheme(Ref ref) {
  // Light theme
  final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF005B8C),
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: lightScheme,
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
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightScheme.surface,
      contentTextStyle: TextStyle(
        color: lightScheme.onSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightScheme.surface,
      surfaceTintColor: lightScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightScheme.surface,
      surfaceTintColor: lightScheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightScheme.surface,
      surfaceTintColor: lightScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
    ),
  );
}

@riverpod
ThemeData appDarkTheme(Ref ref) {
  // Dark theme
  final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(primary: AppColors.primary);
  return ThemeData(
    colorScheme: darkScheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkScheme.surface,
      contentTextStyle: TextStyle(
        color: darkScheme.onSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkScheme.surface,
      surfaceTintColor: darkScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkScheme.surface,
      surfaceTintColor: darkScheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkScheme.surface,
      surfaceTintColor: darkScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
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
Future<SentryState> sentryState(Ref ref) async {
  final service = await ref.watch(sentryServiceProvider.future);
  return SentryState(
    isEnabled: service.isEnabled,
    isReplayEnabled: service.isReplayEnabled,
  );
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) {
  return ShareService();
}

// Repositories
@riverpod
Future<ScheduleRepository> scheduleRepository(Ref ref) async {
  final SchedulesDao schedules = await ref.watch(schedulesDaoProvider.future);
  final DutyTypesDao dutyTypes = await ref.watch(dutyTypesDaoProvider.future);
  return data_repos.ScheduleRepositoryImpl(schedules, dutyTypes);
}

@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final SettingsDao dao = await ref.watch(settingsDaoProvider.future);
  return data_repos.SettingsRepositoryImpl(dao);
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
