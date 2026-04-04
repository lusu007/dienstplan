import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart' as domain;
import 'package:dienstplan/data/models/duty_schedule_config.dart' as data;
import 'package:dienstplan/data/models/mappers/config_mapper.dart' as mapper;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart'
    as domain_repo;

class ConfigRepositoryImpl implements domain_repo.ConfigRepository {
  final ScheduleConfigService _configService;
  final ExceptionMapper _exceptionMapper;

  ConfigRepositoryImpl(this._configService, {ExceptionMapper? exceptionMapper})
    : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  @override
  Future<Result<List<domain.DutyScheduleConfig>>> getConfigs() async {
    try {
      AppLogger.d('ConfigRepository: Getting configs');
      final dataConfigs = _configService.configs;
      final domainConfigs = dataConfigs.map(_toDomainConfig).toList();
      AppLogger.d(
        'ConfigRepository: Retrieved ${domainConfigs.length} configs',
      );
      return Result.success<List<domain.DutyScheduleConfig>>(domainConfigs);
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepository: Error getting configs', e, stackTrace);
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<domain.DutyScheduleConfig>>(failure);
    }
  }

  @override
  Future<Result<domain.DutyScheduleConfig?>> getDefaultConfig() async {
    try {
      AppLogger.d('ConfigRepository: Getting default config');
      final config = _configService.defaultConfig;
      if (config == null) {
        return Result.success<domain.DutyScheduleConfig?>(null);
      }
      final domainConfig = _toDomainConfig(config);
      AppLogger.d('ConfigRepository: Default config: ${domainConfig.name}');
      return Result.success<domain.DutyScheduleConfig?>(domainConfig);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ConfigRepository: Error getting default config',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<domain.DutyScheduleConfig?>(failure);
    }
  }

  @override
  Future<Result<void>> saveConfig(domain.DutyScheduleConfig config) async {
    try {
      AppLogger.d('ConfigRepository: Saving config: ${config.name}');
      final dataConfig = _toDataConfig(config);
      await _configService.saveConfig(dataConfig);
      AppLogger.d('ConfigRepository: Config saved successfully');
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e('ConfigRepository: Error saving config', e, stackTrace);
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<Result<void>> setDefaultConfig(
    domain.DutyScheduleConfig config,
  ) async {
    try {
      AppLogger.d('ConfigRepository: Setting default config: ${config.name}');
      final dataConfig = _toDataConfig(config);
      await _configService.setDefaultConfig(dataConfig);
      AppLogger.d('ConfigRepository: Default config set successfully');
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'ConfigRepository: Error setting default config',
        e,
        stackTrace,
      );
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
