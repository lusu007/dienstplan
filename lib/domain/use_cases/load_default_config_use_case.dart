import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class LoadDefaultConfigUseCase {
  final ConfigRepository _configRepository;

  LoadDefaultConfigUseCase(this._configRepository);

  Future<DutyScheduleConfig?> execute() async {
    try {
      AppLogger.i('LoadDefaultConfigUseCase: Loading default config');

      final defaultConfig = await _configRepository.getDefaultConfig();

      if (defaultConfig != null) {
        AppLogger.i(
            'LoadDefaultConfigUseCase: Default config loaded: ${defaultConfig.name}');
      } else {
        AppLogger.i('LoadDefaultConfigUseCase: No default config found');
      }

      return defaultConfig;
    } catch (e, stackTrace) {
      AppLogger.e('LoadDefaultConfigUseCase: Error loading default config', e,
          stackTrace);
      rethrow;
    }
  }

  Future<DutyScheduleConfig?> executeWithFallback() async {
    try {
      AppLogger.i(
          'LoadDefaultConfigUseCase: Loading default config with fallback');

      // Try to get default config
      final defaultConfig = await _configRepository.getDefaultConfig();

      if (defaultConfig != null) {
        AppLogger.i(
            'LoadDefaultConfigUseCase: Default config loaded: ${defaultConfig.name}');
        return defaultConfig;
      }

      // Fallback: Get first available config
      final configs = await _configRepository.getConfigs();
      if (configs.isNotEmpty) {
        final fallbackConfig = configs.first;
        AppLogger.i(
            'LoadDefaultConfigUseCase: Using fallback config: ${fallbackConfig.name}');
        return fallbackConfig;
      }

      AppLogger.i('LoadDefaultConfigUseCase: No configs available');
      return null;
    } catch (e, stackTrace) {
      AppLogger.e(
          'LoadDefaultConfigUseCase: Error loading default config with fallback',
          e,
          stackTrace);
      rethrow;
    }
  }
}
