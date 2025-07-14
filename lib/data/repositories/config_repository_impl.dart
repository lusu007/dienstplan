import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/data/models/duty_type.dart' as data_duty_type;
import 'package:dienstplan/core/utils/logger.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ScheduleConfigService _configService;

  ConfigRepositoryImpl(this._configService);

  @override
  Future<List<DutyScheduleConfig>> getConfigs() async {
    try {
      AppLogger.i('ConfigRepositoryImpl: Getting configs');
      final dataConfigs = _configService.configs;

      final domainConfigs =
          dataConfigs.map((config) => _toDomainConfig(config)).toList();
      AppLogger.i(
          'ConfigRepositoryImpl: Retrieved ${domainConfigs.length} configs');

      return domainConfigs;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepositoryImpl: Error getting configs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DutyScheduleConfig?> getDefaultConfig() async {
    try {
      AppLogger.i('ConfigRepositoryImpl: Getting default config');
      await _configService.initialize(); // Stelle sicher, dass geladen wurde
      if (!_configService.hasDefaultConfig) {
        AppLogger.i('ConfigRepositoryImpl: No default config found');
        return null;
      }
      final defaultConfig = _configService.defaultConfig;
      if (defaultConfig != null) {
        final domainConfig = _toDomainConfig(defaultConfig);
        AppLogger.i(
            'ConfigRepositoryImpl: Retrieved default config:  [33m${domainConfig.name} [0m');
        return domainConfig;
      }
      AppLogger.i('ConfigRepositoryImpl: Default config is null');
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigRepositoryImpl: Error getting default config', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveConfig(DutyScheduleConfig config) async {
    try {
      AppLogger.i(
          'ConfigRepositoryImpl: Saving config:  [33m${config.name} [0m');
      // Speichere die Konfiguration als Datei
      await _configService.saveConfig(_toDataConfig(config));
      // Setze die Konfiguration als Default
      await _configService.setDefaultConfig(_toDataConfig(config));
      AppLogger.i('ConfigRepositoryImpl: Config saved and set as default');
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepositoryImpl: Error saving config', e, stackTrace);
      rethrow;
    }
  }

  // Mapping helper
  DutyScheduleConfig _toDomainConfig(data.DutyScheduleConfig config) {
    // Since both domain and data models have the same structure,
    // we can create a new instance with the same data
    return DutyScheduleConfig(
      version: config.version,
      meta: _toDomainMeta(config.meta),
      dutyTypes: config.dutyTypes
          .map((key, value) => MapEntry(key, _toDomainDutyType(value))),
      dutyTypeOrder: List<String>.from(config.dutyTypeOrder),
      rhythms: config.rhythms
          .map((key, value) => MapEntry(key, _toDomainRhythm(value))),
      dutyGroups:
          config.dutyGroups.map((group) => _toDomainDutyGroup(group)).toList(),
    );
  }

  // Helper mapping methods for nested objects
  Meta _toDomainMeta(data.Meta meta) => Meta(
        name: meta.name,
        description: meta.description,
        startDate: meta.startDate,
        startWeekDay: meta.startWeekDay,
        days: List<String>.from(meta.days),
        icon: meta.icon,
      );

  DutyType _toDomainDutyType(data_duty_type.DutyType dutyType) => DutyType(
        label: dutyType.label,
        isAllDay: dutyType.isAllDay,
        icon: dutyType.icon,
      );

  Rhythm _toDomainRhythm(data.Rhythm rhythm) => Rhythm(
        lengthWeeks: rhythm.lengthWeeks,
        pattern: rhythm.pattern.map((week) => List<String>.from(week)).toList(),
      );

  DutyGroup _toDomainDutyGroup(data.DutyGroup dutyGroup) => DutyGroup(
        id: dutyGroup.id,
        name: dutyGroup.name,
        rhythm: dutyGroup.rhythm,
        offsetWeeks: dutyGroup.offsetWeeks,
      );

  // Mapping von Domain zu Data Model
  data.DutyScheduleConfig _toDataConfig(DutyScheduleConfig config) {
    return data.DutyScheduleConfig(
      version: config.version,
      meta: data.Meta(
        name: config.meta.name,
        description: config.meta.description,
        startDate: config.meta.startDate,
        startWeekDay: config.meta.startWeekDay,
        days: List<String>.from(config.meta.days),
        icon: config.meta.icon,
      ),
      dutyTypes: config.dutyTypes.map((key, value) => MapEntry(
          key,
          data_duty_type.DutyType(
            label: value.label,
            isAllDay: value.isAllDay,
            icon: value.icon,
          ))),
      dutyTypeOrder: List<String>.from(config.dutyTypeOrder),
      rhythms: config.rhythms.map((key, value) => MapEntry(
          key,
          data.Rhythm(
            lengthWeeks: value.lengthWeeks,
            pattern:
                value.pattern.map((week) => List<String>.from(week)).toList(),
          ))),
      dutyGroups: config.dutyGroups
          .map((group) => data.DutyGroup(
                id: group.id,
                name: group.name,
                rhythm: group.rhythm,
                offsetWeeks: group.offsetWeeks,
              ))
          .toList(),
    );
  }
}
