import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart' as domain;
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/data/models/mappers/config_mapper.dart' as mapper;
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
    return mapper.toDomainConfig(config);
  }

  data.DutyScheduleConfig _toDataConfig(domain.DutyScheduleConfig config) {
    return mapper.toDataConfig(config);
  }
}
