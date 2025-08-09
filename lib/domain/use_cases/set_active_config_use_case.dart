import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/data/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class SetActiveConfigUseCase {
  final ConfigRepository _configRepository;
  final ExceptionMapper _exceptionMapper;

  SetActiveConfigUseCase(this._configRepository,
      {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  Future<void> execute(String configName) async {
    try {
      AppLogger.i('SetActiveConfigUseCase: Setting active config: $configName');

      // Validate input parameter
      if (configName.isEmpty) {
        throw ArgumentError('Config name cannot be empty');
      }

      // Business logic: Validate config exists
      final configs = await _configRepository.getConfigs();

      if (configs.isEmpty) {
        throw ArgumentError('No configurations available');
      }

      final configExists = configs.any((config) => config.name == configName);

      if (!configExists) {
        throw ArgumentError('Configuration not found: $configName');
      }

      // Business logic: Validate config is valid
      final config = configs.firstWhere((config) => config.name == configName);
      _validateConfig(config);

      // Save the active config (implementation depends on your storage strategy)
      await _configRepository.saveConfig(config);

      AppLogger.i(
          'SetActiveConfigUseCase: Active config set successfully: $configName');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SetActiveConfigUseCase: Error setting active config', e, stackTrace);
      rethrow;
    }
  }

  Future<Result<void>> executeSafe(String configName) async {
    try {
      await execute(configName);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  void _validateConfig(DutyScheduleConfig config) {
    // Business logic: Validate configuration before setting as active

    // Check if config has duty types
    if (config.dutyTypes.isEmpty) {
      throw ArgumentError(
          'Configuration "${config.name}" must have at least one duty type');
    }

    // Check if config has duty groups
    if (config.dutyGroups.isEmpty) {
      throw ArgumentError(
          'Configuration "${config.name}" must have at least one duty group');
    }

    // Check if config has rhythms
    if (config.rhythms.isEmpty) {
      throw ArgumentError(
          'Configuration "${config.name}" must have at least one rhythm');
    }

    // Validate that all duty groups reference valid rhythms
    for (final dutyGroup in config.dutyGroups) {
      if (!config.rhythms.containsKey(dutyGroup.rhythm)) {
        throw ArgumentError(
            'Duty group "${dutyGroup.name}" in configuration "${config.name}" references invalid rhythm: ${dutyGroup.rhythm}');
      }
    }

    AppLogger.d(
        'SetActiveConfigUseCase: Config validation passed for ${config.name}');
  }
}
