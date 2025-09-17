import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart';
import 'package:dienstplan/data/daos/schedule_configs_dao.dart';
import 'package:dienstplan/data/daos/schedules_dao.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/data/services/notification_service.dart';
import 'package:dienstplan/core/l10n/app_localizations_de.dart';

class ScheduleConfigService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ScheduleConfigsDao _scheduleConfigsDao;
  final SchedulesDao _schedulesDao;
  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _defaultConfig;
  late Directory _configsPath;
  static const String _configDirName = 'configs';
  static const String _setupCompletedKey = kPrefsKeySetupCompleted;

  ScheduleConfigService(
    this._prefs,
    this._scheduleConfigsDao,
    this._schedulesDao,
  );

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get defaultConfig => _defaultConfig;
  bool get hasDefaultConfig => _defaultConfig != null;
  bool get isSetupCompleted => _prefs.getBool(_setupCompletedKey) ?? false;

  /// Debug method to log current config state
  void logConfigState() {
    AppLogger.i('Current config state:');
    for (final config in _configs) {
      AppLogger.i('  - ${config.name} (version ${config.version})');
    }
  }

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _configsPath = Directory(path.join(appDir.path, _configDirName));
      if (!_configsPath.existsSync()) {
        await _configsPath.create(recursive: true);
      }
      await _loadConfigs();
      await _cleanupOldConfigFiles();
      await _checkVersionsAndInvalidateSchedules();
      logConfigState();
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing ScheduleConfigService', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _loadConfigs() async {
    try {
      AppLogger.i('Loading schedule configurations');
      final configs = await _loadConfigFiles();
      _configs = configs;
      AppLogger.i('Loaded ${_configs.length} schedule configurations');

      // Only try to load default config if we have configs
      if (_configs.isNotEmpty) {
        _defaultConfig = await _loadDefaultConfig();
        AppLogger.i('Default config: ${_defaultConfig?.name ?? 'none'}');
      } else {
        AppLogger.w('No configs loaded, skipping default config');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedule configurations', e, stackTrace);
      rethrow;
    }
  }

  Future<List<DutyScheduleConfig>> _loadConfigFiles() async {
    final List<DutyScheduleConfig> configs = [];
    final Map<String, DutyScheduleConfig> configsByName = {};

    try {
      AppLogger.i('Loading schedule configs from assets and app directory');

      // First, always copy the latest versions from assets to app directory
      await _syncAssetsToAppDirectory();

      // Then load from app directory (which now has the latest versions)
      final files = await _configsPath.list().toList();
      AppLogger.i('Found ${files.length} files in app directory');

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final jsonString = await file.readAsString();
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final config = DutyScheduleConfig.fromMap(json);

            configsByName[config.name] = config;
            AppLogger.i(
              'Loaded config from app directory: ${config.name} (version ${config.version})',
            );
          } catch (e) {
            AppLogger.e('Error loading config file ${file.path}: $e');
          }
        }
      }

      // Convert map values to list
      configs.addAll(configsByName.values);
      AppLogger.i('Total configs loaded: ${configs.length}');
    } catch (e) {
      AppLogger.e('Error loading config files', e);
    }
    return configs;
  }

  /// Syncs all schedule config files from assets to app directory
  /// This ensures the app directory always has the latest versions
  Future<void> _syncAssetsToAppDirectory() async {
    try {
      AppLogger.i('Syncing schedule configs from assets to app directory');

      // Load asset manifest to find all schedule files
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final scheduleFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/schedules/'))
          .where((String key) => key.endsWith('.json'))
          .toList();

      AppLogger.i('Found ${scheduleFiles.length} schedule files in assets');

      int copiedCount = 0;
      for (final assetFile in scheduleFiles) {
        try {
          // Load the asset file
          final jsonString = await rootBundle.loadString(assetFile);
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final config = DutyScheduleConfig.fromMap(json);

          // Save to app directory
          final fileName = path.basename(assetFile);
          final configFile = File(path.join(_configsPath.path, fileName));
          await configFile.writeAsString(jsonString);

          AppLogger.i(
            'Synced config from assets: ${config.name} (version ${config.version})',
          );
          copiedCount++;
        } catch (e) {
          AppLogger.e('Error syncing config file $assetFile: $e');
        }
      }

      AppLogger.i(
        'Successfully synced $copiedCount config files from assets to app directory',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error syncing assets to app directory', e, stackTrace);
      // Don't rethrow - we want to continue with whatever configs we can load
    }
  }

  Future<void> saveConfig(DutyScheduleConfig config) async {
    try {
      // Save to file system
      final file = File('${_configsPath.path}/${config.name}.json');
      final json = config.toMap();
      await file.writeAsString(jsonEncode(json));

      // Save to database
      await _scheduleConfigsDao.saveScheduleConfig(
        name: config.name,
        version: config.version,
        displayName: config.meta.name,
        description: config.meta.description,
        policeAuthority: config.meta.policeAuthority,
        icon: config.meta.icon,
        startDate: config.meta.startDate,
        startWeekDay: config.meta.startWeekDay,
        days: config.meta.days,
      );
    } catch (e) {
      AppLogger.e('Error saving config: $e');
      rethrow;
    }
  }

  int floorDiv(int a, int b) {
    // Ensure positive division for negative numbers
    if (a < 0) {
      return -((-a + b - 1) ~/ b);
    }
    return a ~/ b;
  }

  Future<List<Schedule>> generateSchedulesForConfig(
    DutyScheduleConfig config, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.i('Generating schedules for config: ${config.name}');
    final schedules = <Schedule>[];

    final effectiveStartDate = startDate ?? config.startDate;
    final effectiveEndDate =
        endDate ?? config.startDate.add(const Duration(days: 27375));

    final daysToGenerate = effectiveEndDate
        .difference(effectiveStartDate)
        .inDays;
    AppLogger.i(
      'Generating schedules for ${daysToGenerate + 1} days from ${effectiveStartDate.toIso8601String()} to ${effectiveEndDate.toIso8601String()}',
    );

    // Pre-calculate normalized start date
    final normalizedStartDate = DateTime.utc(
      config.startDate.year,
      config.startDate.month,
      config.startDate.day,
    );

    // Pre-calculate rhythm patterns for better performance
    final rhythmPatterns = <String, List<List<String>>>{};
    for (final dutyGroup in config.dutyGroups) {
      final rhythm = config.rhythms[dutyGroup.rhythm];
      if (rhythm != null) {
        rhythmPatterns[dutyGroup.rhythm] = rhythm.pattern;
      }
    }

    // Pre-calculate duty types for better performance
    final dutyTypes = config.dutyTypes;

    // Use more efficient batch processing
    const batchSize = 1000;
    for (
      var batchStart = 0;
      batchStart <= daysToGenerate;
      batchStart += batchSize
    ) {
      final batchEnd = (batchStart + batchSize - 1).clamp(0, daysToGenerate);
      final batchSchedules = <Schedule>[];

      for (var i = batchStart; i <= batchEnd; i++) {
        final date = effectiveStartDate.add(Duration(days: i));
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);

        final deltaDays = normalizedDate.difference(normalizedStartDate).inDays;

        for (final dutyGroup in config.dutyGroups) {
          final rhythmPattern = rhythmPatterns[dutyGroup.rhythm];
          if (rhythmPattern == null) {
            AppLogger.w('Rhythm not found for duty group: ${dutyGroup.name}');
            continue;
          }

          final rhythm = config.rhythms[dutyGroup.rhythm]!;
          final rawWeekIndex =
              floorDiv(deltaDays, 7) - dutyGroup.offsetWeeks.toInt();
          final weekIndex =
              ((rawWeekIndex % rhythm.lengthWeeks) + rhythm.lengthWeeks) %
              rhythm.lengthWeeks;
          final dayIndex = ((deltaDays % 7) + 7) % 7;

          if (weekIndex >= 0 &&
              weekIndex < rhythmPattern.length &&
              dayIndex >= 0 &&
              dayIndex < rhythmPattern[weekIndex].length) {
            final dutyTypeId = rhythmPattern[weekIndex][dayIndex];
            final dutyType = dutyTypes[dutyTypeId];

            if (dutyType == null) {
              AppLogger.w('Duty type not found: $dutyTypeId');
              continue;
            }

            final schedule = Schedule(
              date: normalizedDate,
              configName: config.name,
              dutyGroupId: dutyGroup.id,
              dutyGroupName: dutyGroup.name,
              service: dutyType.label,
              dutyTypeId: dutyTypeId,
              isAllDay: dutyType.isAllDay,
            );

            batchSchedules.add(schedule);
          }
        }
      }

      schedules.addAll(batchSchedules);

      // Log progress for large generations
      if (daysToGenerate > 100) {
        final progress = ((batchEnd + 1) / (daysToGenerate + 1) * 100).round();
        AppLogger.i(
          'Schedule generation progress: $progress% (${schedules.length} schedules generated)',
        );
      }
    }

    AppLogger.i('Generated ${schedules.length} schedules for ${config.name}');
    return schedules;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> setDefaultConfig(DutyScheduleConfig config) async {
    try {
      AppLogger.i('Setting default config: ${config.name}');
      await _prefs.setString(kPrefsKeyDefaultConfig, config.name);
      _defaultConfig = config;
      AppLogger.i('Default config saved to SharedPreferences');
    } catch (e) {
      AppLogger.e('Error setting default config', e);
      rethrow;
    }
  }

  Future<void> markSetupCompleted() async {
    try {
      AppLogger.i('Marking setup as completed');
      await _prefs.setBool(_setupCompletedKey, true);
      AppLogger.i('Setup completion flag saved to SharedPreferences');
    } catch (e) {
      AppLogger.e('Error marking setup as completed', e);
      rethrow;
    }
  }

  Future<void> resetSetup() async {
    try {
      AppLogger.i('Resetting setup state');
      await _prefs.remove(kPrefsKeyDefaultConfig);
      await _prefs.remove(_setupCompletedKey);
      _defaultConfig = null;
      AppLogger.i('Setup state reset');
    } catch (e) {
      AppLogger.e('Error resetting setup state', e);
      rethrow;
    }
  }

  Future<DutyScheduleConfig?> _loadDefaultConfig() async {
    try {
      final defaultConfigName = _prefs.getString(kPrefsKeyDefaultConfig);
      if (defaultConfigName == null) return null;

      return _configs.firstWhere(
        (config) => config.name == defaultConfigName,
        orElse: () => throw Exception('Default config not found'),
      );
    } catch (e) {
      AppLogger.e('Error loading default config', e);
      return null;
    }
  }

  Future<void> _checkVersionsAndInvalidateSchedules() async {
    try {
      AppLogger.i('Checking schedule config versions');

      final List<Map<String, String>> updatedConfigs = [];

      for (final config in _configs) {
        AppLogger.i(
          'Checking config: ${config.name} (version ${config.version})',
        );

        // Get stored version from database
        final storedConfigData = await _scheduleConfigsDao
            .getScheduleConfigByName(config.name);

        if (storedConfigData != null) {
          final storedVersion = storedConfigData['version'] as String;
          AppLogger.i('Stored version for ${config.name}: $storedVersion');

          // Check if version has changed
          if (storedVersion != config.version) {
            AppLogger.i(
              'Version mismatch for config ${config.name}: stored=$storedVersion, current=${config.version}. Invalidating schedules.',
            );

            // Delete all schedules for this config
            await _schedulesDao.deleteSchedulesByConfigName(config.name);

            // Update the stored config with new version
            await _scheduleConfigsDao.saveScheduleConfig(
              name: config.name,
              version: config.version,
              displayName: config.meta.name,
              description: config.meta.description,
              policeAuthority: config.meta.policeAuthority,
              icon: config.meta.icon,
              startDate: config.meta.startDate,
              startWeekDay: config.meta.startWeekDay,
              days: config.meta.days,
            );

            // Track updated config for notification
            updatedConfigs.add({
              'name': config.meta.name,
              'oldVersion': storedVersion,
              'newVersion': config.version,
            });

            AppLogger.i(
              'Updated config ${config.name} to version ${config.version}',
            );
          } else {
            AppLogger.i(
              'Config ${config.name} version ${config.version} is up to date',
            );
          }
        } else {
          // Config not in database yet, save it
          AppLogger.i(
            'New config ${config.name} version ${config.version}, saving to database',
          );
          await _scheduleConfigsDao.saveScheduleConfig(
            name: config.name,
            version: config.version,
            displayName: config.meta.name,
            description: config.meta.description,
            policeAuthority: config.meta.policeAuthority,
            icon: config.meta.icon,
            startDate: config.meta.startDate,
            startWeekDay: config.meta.startWeekDay,
            days: config.meta.days,
          );
        }
      }

      // Show notifications for updated configs
      AppLogger.i(
        'Found ${updatedConfigs.length} configs that need notifications',
      );
      if (updatedConfigs.isNotEmpty) {
        AppLogger.i(
          'Configs to notify about: ${updatedConfigs.map((c) => '${c['name']} (${c['oldVersion']} → ${c['newVersion']})').join(', ')}',
        );
        _showUpdateNotifications(updatedConfigs);
      } else {
        AppLogger.i('No config updates found, no notifications needed');
      }

      AppLogger.i('Schedule config version check completed');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error checking versions and invalidating schedules',
        e,
        stackTrace,
      );
      // Don't rethrow - we don't want to prevent app startup due to version check failure
    }
  }

  void _showUpdateNotifications(List<Map<String, String>> updatedConfigs) {
    try {
      // Use post-frame callback to ensure UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNotificationsAfterFrame(updatedConfigs);
      });
    } catch (e, stackTrace) {
      AppLogger.e('Error scheduling update notifications', e, stackTrace);
    }
  }

  void _showNotificationsAfterFrame(List<Map<String, String>> updatedConfigs) {
    try {
      final notificationService = NotificationService();

      // Get the current locale for localization
      // Note: We'll need to get this from the app context or a service
      // For now, we'll use a default German localization
      final l10n = AppLocalizationsDe();

      if (updatedConfigs.length == 1) {
        // Single config update
        final config = updatedConfigs.first;
        notificationService.showScheduleUpdateNotification(
          configName: config['name']!,
          oldVersion: config['oldVersion']!,
          newVersion: config['newVersion']!,
          l10n: l10n,
        );
      } else {
        // Multiple config updates
        final configNames = updatedConfigs.map((c) => c['name']!).toList();
        notificationService.showMultipleScheduleUpdatesNotification(
          configNames: configNames,
          l10n: l10n,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error showing update notifications', e, stackTrace);
    }
  }

  Future<void> _cleanupOldConfigFiles() async {
    try {
      AppLogger.i('Cleaning up old config files');

      // Since we now always sync from assets, we can be more aggressive in cleanup
      // Delete any files that are not in the current assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final assetConfigNames = manifestMap.keys
          .where((String key) => key.startsWith('assets/schedules/'))
          .where((String key) => key.endsWith('.json'))
          .map((String key) => path.basenameWithoutExtension(key))
          .toList();

      final files = await _configsPath.list().toList();
      int deletedCount = 0;
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = path.basenameWithoutExtension(file.path);
          if (!assetConfigNames.contains(fileName)) {
            AppLogger.i('Deleting obsolete config file: ${file.path}');
            await file.delete();
            deletedCount++;
          }
        }
      }
      AppLogger.i(
        'Cleanup of old config files completed. Deleted $deletedCount obsolete files.',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error cleaning up old config files', e, stackTrace);
    }
  }
}
