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
import 'package:dienstplan/data/daos/schedules_admin_dao.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/data/services/notification_service.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/l10n/app_localizations_de.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleConfigService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ScheduleConfigsDao _scheduleConfigsDao;
  final SchedulesAdminDao _schedulesAdminDao;
  final DatabaseService _databaseService;
  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _defaultConfig;
  late Directory _configsPath;
  static const String _configDirName = 'configs';
  static const String _setupCompletedKey = kPrefsKeySetupCompleted;

  ScheduleConfigService(
    this._prefs,
    this._scheduleConfigsDao,
    this._schedulesAdminDao,
    this._databaseService,
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

            // Only overwrite if this config has a higher version or if no config exists yet
            final existingConfig = configsByName[config.name];
            if (existingConfig == null ||
                _compareVersions(config.version, existingConfig.version) > 0) {
              configsByName[config.name] = config;
              AppLogger.i(
                'Loaded config from app directory: ${config.name} (version ${config.version})',
              );
            } else {
              // Delete the older file since we have a newer version
              AppLogger.i(
                'Deleting outdated config file: ${file.path} (version ${config.version}, newer version ${existingConfig.version} exists)',
              );
              await file.delete();
            }
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

          // Always overwrite existing files to ensure we have the latest version
          if (configFile.existsSync()) {
            await configFile.delete();
          }
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
      // Note: Config files are read-only from assets, do not save to file system
      // Only save metadata to database for version tracking
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

  /// Compares two version strings (e.g., "1.2" vs "1.0")
  /// Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
  /// Handles version strings with non-numeric parts (e.g., "1.2-beta", "2.0.0-rc1")
  int _compareVersions(String version1, String version2) {
    final parts1 = _parseVersionParts(version1);
    final parts2 = _parseVersionParts(version2);

    final maxLength = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final v1 = i < parts1.length ? parts1[i] : 0;
      final v2 = i < parts2.length ? parts2[i] : 0;

      if (v1 > v2) return 1;
      if (v1 < v2) return -1;
    }

    return 0;
  }

  /// Parses version string parts, handling non-numeric suffixes
  /// Extracts only the numeric part from each version segment
  /// Examples: "1.2-beta" -> [1, 2], "2.0.0-rc1" -> [2, 0, 0]
  List<int> _parseVersionParts(String version) {
    try {
      return version.split('.').map((part) {
        // Extract only the numeric part from each segment
        final match = RegExp(r'^\d+').firstMatch(part);
        if (match != null) {
          return int.parse(match.group(0)!);
        }
        // If no numeric part found, default to 0
        return 0;
      }).toList();
    } catch (e) {
      AppLogger.w('Failed to parse version parts for "$version": $e');
      // Return a default version (0.0.0) if parsing fails
      return [0];
    }
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

            // Delete all schedules and duty types for this config
            await _schedulesAdminDao.clearDutySchedule(config.name);

            // The config file is already up-to-date from _syncAssetsToAppDirectory()
            // Just update the database with the new config data
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

            // Reload the config into memory to ensure start_date and other metadata are fresh
            final configIndex = _configs.indexWhere(
              (c) => c.name == config.name,
            );
            if (configIndex >= 0) {
              _configs[configIndex] = config;
              AppLogger.i(
                'Reloaded config ${config.name} into memory with start_date: ${config.meta.startDate.toIso8601String()}',
              );
            } else {
              AppLogger.w(
                'Could not find config ${config.name} in _configs list to reload',
              );
            }

            // Note: Schedule data cache will be invalidated automatically
            // when the ScheduleDataNotifier._invalidateCacheOnVersionChange()
            // method detects the version change on next app startup
            AppLogger.i(
              'Config ${config.name} database updated - schedule caches will be invalidated on next load',
            );

            // Generate new schedules for the updated config to ensure services are positioned correctly
            try {
              AppLogger.i(
                'Generating new schedules for updated config ${config.name}',
              );
              final now = DateTime.now();
              final startDate = DateTime(now.year, now.month, 1);
              final endDate = DateTime(
                now.year,
                now.month + 3,
                0,
              ); // Generate 3 months ahead

              final newSchedules = await generateSchedulesForConfig(
                config,
                startDate: startDate,
                endDate: endDate,
              );

              // Save the generated schedules to database
              if (newSchedules.isNotEmpty) {
                await _saveSchedulesToDatabase(newSchedules);
                AppLogger.i(
                  'Saved ${newSchedules.length} new schedules to database for ${config.name}',
                );
              } else {
                AppLogger.w('No schedules generated for ${config.name}');
              }
            } catch (e) {
              AppLogger.w(
                'Failed to generate schedules for ${config.name}: $e',
              );
            }

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
          // Config not in database yet, save it (file + DB)
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

      // Also get the config names from assets to detect duplicates
      final Map<String, String> configNameToFileName = {};

      // Build a map of config names to their asset file names
      for (final assetFile
          in manifestMap.keys
              .where((String key) => key.startsWith('assets/schedules/'))
              .where((String key) => key.endsWith('.json'))) {
        try {
          final jsonString = await rootBundle.loadString(assetFile);
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final configName = json['meta']['name'] as String;
          final fileName = path.basenameWithoutExtension(assetFile);
          configNameToFileName[configName] = fileName;
        } catch (e) {
          AppLogger.w('Error reading asset file $assetFile during cleanup: $e');
        }
      }

      final files = await _configsPath.list().toList();
      int deletedCount = 0;
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = path.basenameWithoutExtension(file.path);
          bool shouldDelete = false;

          // Delete if file name is not in assets
          if (!assetConfigNames.contains(fileName)) {
            shouldDelete = true;
            AppLogger.i(
              'Deleting obsolete config file (not in assets): ${file.path}',
            );
          } else {
            // Check if this file has a config name that conflicts with assets
            try {
              final jsonString = await file.readAsString();
              final json = jsonDecode(jsonString) as Map<String, dynamic>;
              final configName = json['meta']['name'] as String;
              final configVersion = json['version'] as String;
              final expectedFileName = configNameToFileName[configName];

              if (expectedFileName != null && expectedFileName != fileName) {
                shouldDelete = true;
                AppLogger.i(
                  'Deleting duplicate config file (name conflict): ${file.path} (config: $configName, expected file: $expectedFileName)',
                );
              } else if (expectedFileName != null &&
                  expectedFileName == fileName) {
                // This is the correct asset file, but check if it's outdated
                // We'll let the version comparison in _loadConfigFiles handle this
                AppLogger.d(
                  'Keeping asset file: ${file.path} (config: $configName, version: $configVersion)',
                );
              }
            } catch (e) {
              AppLogger.w(
                'Error reading config file ${file.path} during cleanup: $e',
              );
              shouldDelete = true;
            }
          }

          if (shouldDelete) {
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

  /// Saves generated schedules to the database
  Future<void> _saveSchedulesToDatabase(List<Schedule> schedules) async {
    try {
      final db = await _databaseService.database;
      final batch = db.batch();

      // Store timestamp once to avoid multiple DateTime.now() calls
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (final schedule in schedules) {
        batch.insert('schedules', {
          'date': schedule.date.toIso8601String(),
          'date_ymd': schedule.date.toIso8601String().substring(0, 10),
          'service': schedule.service,
          'duty_group_id': schedule.dutyGroupId,
          'duty_group_name': schedule.dutyGroupName,
          'duty_type_id': schedule.dutyTypeId,
          'is_all_day': schedule.isAllDay ? 1 : 0,
          'config_name': schedule.configName,
          'created_at': timestamp,
          'updated_at': timestamp,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
      AppLogger.i(
        'Successfully saved ${schedules.length} schedules to database',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving schedules to database', e, stackTrace);
      rethrow;
    }
  }
}
