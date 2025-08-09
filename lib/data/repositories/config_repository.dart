import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart' as domain;
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/data/models/mappers/config_mapper.dart' as mapper;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class ConfigRepository {
  final ScheduleConfigService _configService;
  final ExceptionMapper _exceptionMapper;

  ConfigRepository(this._configService, {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

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

  Future<Result<List<domain.DutyScheduleConfig>>> getConfigsSafe() async {
    try {
      final configs = await getConfigs();
      return Result.success<List<domain.DutyScheduleConfig>>(configs);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<domain.DutyScheduleConfig>>(failure);
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

  Future<Result<domain.DutyScheduleConfig?>> getDefaultConfigSafe() async {
    try {
      final config = await getDefaultConfig();
      return Result.success<domain.DutyScheduleConfig?>(config);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<domain.DutyScheduleConfig?>(failure);
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

  Future<Result<void>> saveConfigSafe(domain.DutyScheduleConfig config) async {
    try {
      await saveConfig(config);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
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

  Future<Result<void>> setDefaultConfigSafe(
      domain.DutyScheduleConfig config) async {
    try {
      await setDefaultConfig(config);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  domain.DutyScheduleConfig _toDomainConfig(data.DutyScheduleConfig config) {
    return mapper.toDomainConfig(config);
  }

  data.DutyScheduleConfig _toDataConfig(domain.DutyScheduleConfig config) {
    return mapper.toDataConfig(config);
  }
}
