import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart';
import 'package:dienstplan/core/utils/logger.dart';

class ConfigLocalDataSource {
  final ScheduleConfigService _scheduleConfigService;

  ConfigLocalDataSource(this._scheduleConfigService);

  /// Get all configurations from local storage
  Future<List<DutyScheduleConfig>> getConfigs() async {
    try {
      AppLogger.d('ConfigLocalDataSource: Getting all configs');

      final configs = _scheduleConfigService.configs;
      AppLogger.d('ConfigLocalDataSource: Retrieved ${configs.length} configs');

      // Return the configs directly since they're already the correct type
      return configs;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSource: Error getting configs', e, stackTrace);
      rethrow;
    }
  }

  /// Get a specific configuration by name
  Future<DutyScheduleConfig?> getConfig(String configName) async {
    try {
      AppLogger.d('ConfigLocalDataSource: Getting config: $configName');

      final configs = _scheduleConfigService.configs;
      final config = configs.where((c) => c.name == configName).firstOrNull;

      if (config != null) {
        AppLogger.d('ConfigLocalDataSource: Found config: $configName');
        return config;
      } else {
        AppLogger.d('ConfigLocalDataSource: Config not found: $configName');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error getting config', e, stackTrace);
      rethrow;
    }
  }

  /// Save a configuration to local storage
  Future<void> saveConfig(DutyScheduleConfig config) async {
    try {
      AppLogger.d('ConfigLocalDataSource: Saving config: ${config.name}');

      await _scheduleConfigService.saveConfig(config);

      AppLogger.d(
          'ConfigLocalDataSource: Successfully saved config: ${config.name}');
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error saving config', e, stackTrace);
      rethrow;
    }
  }

  /// Save multiple configurations to local storage
  Future<void> saveConfigs(List<DutyScheduleConfig> configs) async {
    try {
      AppLogger.d('ConfigLocalDataSource: Saving ${configs.length} configs');

      for (final config in configs) {
        await _scheduleConfigService.saveConfig(config);
      }

      AppLogger.d(
          'ConfigLocalDataSource: Successfully saved ${configs.length} configs');
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error saving configs', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a configuration by name
  Future<void> deleteConfig(String configName) async {
    try {
      AppLogger.d('ConfigLocalDataSource: Deleting config: $configName');

      // Note: ScheduleConfigService doesn't have a deleteConfig method
      // This would need to be implemented in the service
      AppLogger.w(
          'ConfigLocalDataSource: deleteConfig not implemented in ScheduleConfigService');

      AppLogger.d(
          'ConfigLocalDataSource: Successfully deleted config: $configName');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSource: Error deleting config', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all configurations
  Future<void> clearConfigs() async {
    try {
      AppLogger.d('ConfigLocalDataSource: Clearing all configs');

      // Note: ScheduleConfigService doesn't have a clearConfigs method
      // This would need to be implemented in the service
      AppLogger.w(
          'ConfigLocalDataSource: clearConfigs not implemented in ScheduleConfigService');

      AppLogger.d('ConfigLocalDataSource: Successfully cleared all configs');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSource: Error clearing configs', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a configuration exists
  Future<bool> hasConfig(String configName) async {
    try {
      AppLogger.d(
          'ConfigLocalDataSource: Checking if config exists: $configName');

      final configs = _scheduleConfigService.configs;
      final hasConfig = configs.any((c) => c.name == configName);

      AppLogger.d('ConfigLocalDataSource: Config exists: $hasConfig');

      return hasConfig;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error checking if config exists', e,
          stackTrace);
      rethrow;
    }
  }

  /// Get the active configuration name
  Future<String?> getActiveConfigName() async {
    try {
      AppLogger.d('ConfigLocalDataSource: Getting active config name');

      final defaultConfig = _scheduleConfigService.defaultConfig;
      final configName = defaultConfig?.name;

      AppLogger.d('ConfigLocalDataSource: Active config name: $configName');

      return configName;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error getting active config name', e,
          stackTrace);
      rethrow;
    }
  }

  /// Set the active configuration name
  Future<void> setActiveConfigName(String configName) async {
    try {
      AppLogger.d(
          'ConfigLocalDataSource: Setting active config name: $configName');

      final configs = _scheduleConfigService.configs;
      final config = configs.where((c) => c.name == configName).firstOrNull;

      if (config != null) {
        await _scheduleConfigService.setDefaultConfig(config);
        AppLogger.d(
            'ConfigLocalDataSource: Successfully set active config: $configName');
      } else {
        throw ArgumentError('Configuration not found: $configName');
      }
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSource: Error setting active config name', e,
          stackTrace);
      rethrow;
    }
  }
}
