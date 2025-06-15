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

  ScheduleConfigService(this._prefs);

  List<DutyScheduleConfig> get configs => _configs;
  DutyScheduleConfig? get defaultConfig => _defaultConfig;
  bool get hasDefaultConfig => _defaultConfig != null;

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
      _defaultConfig = await _loadDefaultConfig();
      AppLogger.i('Loaded ${_configs.length} schedule configurations');
      AppLogger.i('Default config: ${_defaultConfig?.name ?? 'none'}');
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

  int floorDiv(int a, int b) =>
      (a ~/ b) - ((a % b != 0 && a.isNegative) ? 1 : 0);

  Future<List<Schedule>> generateSchedulesForConfig(
      DutyScheduleConfig config) async {
    AppLogger.i('Generating schedules for config: ${config.name}');
    final schedules = <Schedule>[];
    final startDate = config.startDate;

    // Generate schedules for each day
    for (var i = -365; i < 365; i++) {
      final date = startDate.add(Duration(days: i));

      // Generate schedules for each duty group
      for (final dutyGroup in config.dutyGroups) {
        final rhythm = config.rhythms[dutyGroup.rhythm];
        if (rhythm == null) {
          AppLogger.w('Rhythm not found for duty group: ${dutyGroup.name}');
          continue;
        }

        final deltaDays = date.difference(startDate).inDays;
        final rawWeekIndex =
            floorDiv(deltaDays, 7) - dutyGroup.offsetWeeks.toInt();
        final weekIndex =
            ((rawWeekIndex % rhythm.lengthWeeks) + rhythm.lengthWeeks) %
                rhythm.lengthWeeks;
        final dayIndex = (deltaDays % 7 + 7) % 7;

        // Debug logging for specific dates
        if (date.day == 31 && date.month == 7) {
          AppLogger.i('${dutyGroup.name} on ${date.day}.${date.month}:');
          AppLogger.i('Delta days: $deltaDays');
          AppLogger.i(
              'Week index calculation: ($deltaDays ~/ 7) - ${dutyGroup.offsetWeeks} = ${deltaDays ~/ 7 - dutyGroup.offsetWeeks.toInt()}');
          AppLogger.i('Week index: $weekIndex');
          AppLogger.i('Day index: $dayIndex');
        }

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
            date: date,
            configName: config.name,
            dutyGroupId: dutyGroup.id,
            dutyGroupName: dutyGroup.name,
            service: dutyTypeId,
            dutyTypeId: dutyTypeId,
            isAllDay: dutyType.allDay,
          );

          schedules.add(schedule);
        }
      }
    }

    AppLogger.i('Generated ${schedules.length} schedules for ${config.name}');
    return schedules;
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
