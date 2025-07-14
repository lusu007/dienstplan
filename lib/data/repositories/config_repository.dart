import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart' as domain;
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/domain/entities/duty_type.dart' as domain_duty_type;
import 'package:dienstplan/data/models/duty_type.dart' as data_duty_type;
import 'package:dienstplan/core/utils/logger.dart';

class ConfigRepository {
  final ScheduleConfigService _configService;

  ConfigRepository(this._configService);

  Future<List<domain.DutyScheduleConfig>> getConfigs() async {
    try {
      AppLogger.i('ConfigRepository: Getting configs');
      final dataConfigs = _configService.configs;
      final domainConfigs = dataConfigs.map(_toDomainConfig).toList();
      AppLogger.i(
          'ConfigRepository: Retrieved ${domainConfigs.length} configs');
      return domainConfigs;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepository: Error getting configs', e, stackTrace);
      rethrow;
    }
  }

  Future<domain.DutyScheduleConfig?> getDefaultConfig() async {
    try {
      AppLogger.i('ConfigRepository: Getting default config');
      final config = _configService.defaultConfig;
      if (config == null) return null;
      final domainConfig = _toDomainConfig(config);
      AppLogger.i('ConfigRepository: Default config: ${domainConfig.name}');
      return domainConfig;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigRepository: Error getting default config', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveConfig(domain.DutyScheduleConfig config) async {
    try {
      AppLogger.i('ConfigRepository: Saving config: ${config.name}');
      final dataConfig = _toDataConfig(config);
      await _configService.saveConfig(dataConfig);
      AppLogger.i('ConfigRepository: Config saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepository: Error saving config', e, stackTrace);
      rethrow;
    }
  }

  Future<void> setDefaultConfig(domain.DutyScheduleConfig config) async {
    try {
      AppLogger.i('ConfigRepository: Setting default config: ${config.name}');
      final dataConfig = _toDataConfig(config);
      await _configService.setDefaultConfig(dataConfig);
      AppLogger.i('ConfigRepository: Default config set successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigRepository: Error setting default config', e, stackTrace);
      rethrow;
    }
  }

  domain.DutyScheduleConfig _toDomainConfig(data.DutyScheduleConfig config) {
    return domain.DutyScheduleConfig(
      version: config.version,
      meta: _toDomainMeta(config.meta),
      dutyTypes: config.dutyTypes
          .map((key, value) => MapEntry(key, _toDomainDutyType(value))),
      dutyTypeOrder: config.dutyTypeOrder,
      rhythms: config.rhythms
          .map((key, value) => MapEntry(key, _toDomainRhythm(value))),
      dutyGroups: config.dutyGroups.map(_toDomainDutyGroup).toList(),
    );
  }

  data.DutyScheduleConfig _toDataConfig(domain.DutyScheduleConfig config) {
    return data.DutyScheduleConfig(
      version: config.version,
      meta: _toDataMeta(config.meta),
      dutyTypes: config.dutyTypes
          .map((key, value) => MapEntry(key, _toDataDutyType(value))),
      dutyTypeOrder: config.dutyTypeOrder,
      rhythms: config.rhythms
          .map((key, value) => MapEntry(key, _toDataRhythm(value))),
      dutyGroups: config.dutyGroups.map(_toDataDutyGroup).toList(),
    );
  }

  domain.Meta _toDomainMeta(data.Meta meta) {
    return domain.Meta(
      name: meta.name,
      description: meta.description,
      startDate: meta.startDate,
      startWeekDay: meta.startWeekDay,
      days: meta.days,
      icon: meta.icon,
    );
  }

  data.Meta _toDataMeta(domain.Meta meta) {
    return data.Meta(
      name: meta.name,
      description: meta.description,
      startDate: meta.startDate,
      startWeekDay: meta.startWeekDay,
      days: meta.days,
      icon: meta.icon,
    );
  }

  domain_duty_type.DutyType _toDomainDutyType(
      data_duty_type.DutyType dutyType) {
    return domain_duty_type.DutyType(
      label: dutyType.label,
      isAllDay: dutyType.isAllDay,
      icon: dutyType.icon,
    );
  }

  data_duty_type.DutyType _toDataDutyType(domain_duty_type.DutyType dutyType) {
    return data_duty_type.DutyType(
      label: dutyType.label,
      isAllDay: dutyType.isAllDay,
      icon: dutyType.icon,
    );
  }

  domain.Rhythm _toDomainRhythm(data.Rhythm rhythm) {
    return domain.Rhythm(
      lengthWeeks: rhythm.lengthWeeks,
      pattern: rhythm.pattern,
    );
  }

  data.Rhythm _toDataRhythm(domain.Rhythm rhythm) {
    return data.Rhythm(
      lengthWeeks: rhythm.lengthWeeks,
      pattern: rhythm.pattern,
    );
  }

  domain.DutyGroup _toDomainDutyGroup(data.DutyGroup dutyGroup) {
    return domain.DutyGroup(
      id: dutyGroup.id,
      name: dutyGroup.name,
      rhythm: dutyGroup.rhythm,
      offsetWeeks: dutyGroup.offsetWeeks,
    );
  }

  data.DutyGroup _toDataDutyGroup(domain.DutyGroup dutyGroup) {
    return data.DutyGroup(
      id: dutyGroup.id,
      name: dutyGroup.name,
      rhythm: dutyGroup.rhythm,
      offsetWeeks: dutyGroup.offsetWeeks,
    );
  }
}
