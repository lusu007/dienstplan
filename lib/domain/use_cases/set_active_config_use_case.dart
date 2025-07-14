import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class SetActiveConfigUseCase {
  final ConfigRepository _configRepository;

  SetActiveConfigUseCase(this._configRepository);

  Future<void> execute(String configName) async {
    try {
      AppLogger.i('SetActiveConfigUseCase: Setting active config: $configName');

      // Business logic: Validate config exists
      final configs = await _configRepository.getConfigs();
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

  void _validateConfig(DutyScheduleConfig config) {
    // Business logic: Validate configuration before setting as active

    // Check if config has duty types
    if (config.dutyTypes.isEmpty) {
      throw ArgumentError('Configuration must have at least one duty type');
    }

    // Check if config has duty groups
    if (config.dutyGroups.isEmpty) {
      throw ArgumentError('Configuration must have at least one duty group');
    }

    // Check if config has rhythms
    if (config.rhythms.isEmpty) {
      throw ArgumentError('Configuration must have at least one rhythm');
    }

    // Validate that all duty groups reference valid rhythms
    for (final dutyGroup in config.dutyGroups) {
      if (!config.rhythms.containsKey(dutyGroup.rhythm)) {
        throw ArgumentError(
            'Duty group "${dutyGroup.name}" references invalid rhythm: ${dutyGroup.rhythm}');
      }
    }

    AppLogger.d('SetActiveConfigUseCase: Config validation passed');
  }
}
