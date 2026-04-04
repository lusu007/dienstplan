import 'package:dienstplan/domain/entities/duty_group.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class SetActiveConfigUseCase {
  final ConfigRepository _configRepository;

  SetActiveConfigUseCase(this._configRepository);

  Future<Result<void>> execute(String configName) async {
    AppLogger.d('SetActiveConfigUseCase: Setting active config: $configName');
    if (configName.isEmpty) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Validation error: Config name cannot be empty',
        ),
      );
    }
    final Result<List<DutyScheduleConfig>> configsResult =
        await _configRepository.getConfigs();
    if (configsResult.isFailure) {
      return Result.createFailure<void>(configsResult.failure);
    }
    final List<DutyScheduleConfig> configs = configsResult.value;
    if (configs.isEmpty) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Validation error: No configurations available',
        ),
      );
    }
    final bool configExists = configs.any(
      (DutyScheduleConfig config) => config.name == configName,
    );
    if (!configExists) {
      return Result.createFailure<void>(
        ValidationFailure(
          technicalMessage:
              'Validation error: Configuration not found: $configName',
        ),
      );
    }
    final DutyScheduleConfig config = configs.firstWhere(
      (DutyScheduleConfig c) => c.name == configName,
    );
    final Result<void> validation = _validateConfig(config);
    if (validation.isFailure) {
      return validation;
    }
    AppLogger.d(
      'SetActiveConfigUseCase: Active config set successfully: $configName',
    );
    return Result.success<void>(null);
  }

  Result<void> _validateConfig(DutyScheduleConfig config) {
    if (config.dutyTypes.isEmpty) {
      return Result.createFailure<void>(
        ValidationFailure(
          technicalMessage:
              'Configuration "${config.name}" must have at least one duty type',
        ),
      );
    }
    if (config.dutyGroups.isEmpty) {
      return Result.createFailure<void>(
        ValidationFailure(
          technicalMessage:
              'Configuration "${config.name}" must have at least one duty group',
        ),
      );
    }
    if (config.rhythms.isEmpty) {
      return Result.createFailure<void>(
        ValidationFailure(
          technicalMessage:
              'Configuration "${config.name}" must have at least one rhythm',
        ),
      );
    }
    for (final DutyGroup dutyGroup in config.dutyGroups) {
      if (!config.rhythms.containsKey(dutyGroup.rhythm)) {
        return Result.createFailure<void>(
          ValidationFailure(
            technicalMessage:
                'Duty group "${dutyGroup.name}" in configuration "${config.name}" references invalid rhythm: ${dutyGroup.rhythm}',
          ),
        );
      }
    }
    AppLogger.d(
      'SetActiveConfigUseCase: Config validation passed for ${config.name}',
    );
    return Result.success<void>(null);
  }
}
