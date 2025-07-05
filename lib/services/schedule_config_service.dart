import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/utils/logger.dart';

class ScheduleConfigService extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _defaultConfig;
  late Directory _configsPath;
  static const String _configDirName = 'configs';
  static const String _setupCompletedKey = 'setup_completed';

  ScheduleConfigService(this._prefs);

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get defaultConfig => _defaultConfig;
  bool get hasDefaultConfig => _defaultConfig != null;
  bool get isSetupCompleted => _prefs.getBool(_setupCompletedKey) ?? false;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _configsPath = Directory(path.join(appDir.path, _configDirName));
      if (!_configsPath.existsSync()) {
        await _configsPath.create(recursive: true);
      }
      await _loadConfigs();
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
    try {
      // Load from assets first
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final scheduleFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/schedules/'))
          .where((String key) => key.endsWith('.json'))
          .toList();

      for (final file in scheduleFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final config = DutyScheduleConfig.fromMap(json);
          configs.add(config);

          // Save to app directory for future use
          final fileName = path.basename(file);
          final configFile = File(path.join(_configsPath.path, fileName));
          await configFile.writeAsString(jsonString);
        } catch (e) {
          AppLogger.e('Error loading config file $file: $e');
        }
      }

      // Then load from app directory
      final files = await _configsPath.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final jsonString = await file.readAsString();
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final config = DutyScheduleConfig.fromMap(json);
            if (!configs.any((c) => c.name == config.name)) {
              configs.add(config);
            }
          } catch (e) {
            AppLogger.e('Error loading config file ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      AppLogger.e('Error loading config files', e);
    }
    return configs;
  }

  Future<void> saveConfig(DutyScheduleConfig config) async {
    try {
      final file = File('${_configsPath.path}/${config.name}.json');
      final json = config.toMap();
      await file.writeAsString(jsonEncode(json));
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

    final daysToGenerate =
        effectiveEndDate.difference(effectiveStartDate).inDays;
    AppLogger.i(
        'Generating schedules for ${daysToGenerate + 1} days from ${effectiveStartDate.toIso8601String()} to ${effectiveEndDate.toIso8601String()}');

    for (var i = 0; i <= daysToGenerate; i++) {
      final date = effectiveStartDate.add(Duration(days: i));
      // Use UTC dates consistently
      final normalizedDate = DateTime.utc(date.year, date.month, date.day);
      final normalizedStartDate = DateTime.utc(
          config.startDate.year, config.startDate.month, config.startDate.day);

      for (final dutyGroup in config.dutyGroups) {
        final rhythm = config.rhythms[dutyGroup.rhythm];
        if (rhythm == null) {
          AppLogger.w('Rhythm not found for duty group: ${dutyGroup.name}');
          continue;
        }

        final deltaDays = normalizedDate.difference(normalizedStartDate).inDays;
        final rawWeekIndex =
            floorDiv(deltaDays, 7) - dutyGroup.offsetWeeks.toInt();
        final weekIndex =
            ((rawWeekIndex % rhythm.lengthWeeks) + rhythm.lengthWeeks) %
                rhythm.lengthWeeks;
        final dayIndex = ((deltaDays % 7) + 7) % 7;

        if (weekIndex >= 0 &&
            weekIndex < rhythm.pattern.length &&
            dayIndex >= 0 &&
            dayIndex < rhythm.pattern[weekIndex].length) {
          final dutyTypeId = rhythm.pattern[weekIndex][dayIndex];
          final dutyType = config.dutyTypes[dutyTypeId];

          if (dutyType == null) {
            AppLogger.w('Duty type not found: $dutyTypeId');
            continue;
          }

          final schedule = Schedule(
            date: normalizedDate,
            configName: config.name,
            dutyGroupId: dutyGroup.id,
            dutyGroupName: dutyGroup.name,
            service: dutyTypeId,
            dutyTypeId: dutyTypeId,
            isAllDay: dutyType.isAllDay,
          );

          schedules.add(schedule);
        } else if (date.year == 2025 && date.month == 6 && date.day == 30) {
          AppLogger.w(
              'Invalid indices for 2025-06-30: weekIndex=$weekIndex, dayIndex=$dayIndex');
        }
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
      await _prefs.setString('default_config', config.name);
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
      await _prefs.remove('default_config');
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
      final defaultConfigName = _prefs.getString('default_config');
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
}
