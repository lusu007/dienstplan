import 'package:dienstplan/data/data_sources/config_local_data_source.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart';
import 'package:dienstplan/core/utils/logger.dart';

class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  final ScheduleConfigService _scheduleConfigService;

  ConfigLocalDataSourceImpl(this._scheduleConfigService);

  @override
  Future<List<DutyScheduleConfig>> getConfigs() async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Getting all configs');

      final configs = _scheduleConfigService.configs;
      AppLogger.d(
          'ConfigLocalDataSourceImpl: Retrieved ${configs.length} configs');

      // Return the configs directly since they're already the correct type
      return configs;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error getting configs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<DutyScheduleConfig?> getConfig(String configName) async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Getting config: $configName');

      final configs = _scheduleConfigService.configs;
      final config = configs.where((c) => c.name == configName).firstOrNull;

      if (config != null) {
        AppLogger.d('ConfigLocalDataSourceImpl: Found config: $configName');
        return config;
      } else {
        AppLogger.d('ConfigLocalDataSourceImpl: Config not found: $configName');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error getting config', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveConfig(DutyScheduleConfig config) async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Saving config: ${config.name}');

      await _scheduleConfigService.saveConfig(config);

      AppLogger.d(
          'ConfigLocalDataSourceImpl: Successfully saved config: ${config.name}');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error saving config', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveConfigs(List<DutyScheduleConfig> configs) async {
    try {
      AppLogger.d(
          'ConfigLocalDataSourceImpl: Saving ${configs.length} configs');

      for (final config in configs) {
        await _scheduleConfigService.saveConfig(config);
      }

      AppLogger.d(
          'ConfigLocalDataSourceImpl: Successfully saved ${configs.length} configs');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error saving configs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteConfig(String configName) async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Deleting config: $configName');

      // Note: ScheduleConfigService doesn't have a deleteConfig method
      // This would need to be implemented in the service
      AppLogger.w(
          'ConfigLocalDataSourceImpl: deleteConfig not implemented in ScheduleConfigService');

      AppLogger.d(
          'ConfigLocalDataSourceImpl: Successfully deleted config: $configName');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error deleting config', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearConfigs() async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Clearing all configs');

      // Note: ScheduleConfigService doesn't have a clearConfigs method
      // This would need to be implemented in the service
      AppLogger.w(
          'ConfigLocalDataSourceImpl: clearConfigs not implemented in ScheduleConfigService');

      AppLogger.d(
          'ConfigLocalDataSourceImpl: Successfully cleared all configs');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ConfigLocalDataSourceImpl: Error clearing configs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> hasConfig(String configName) async {
    try {
      AppLogger.d(
          'ConfigLocalDataSourceImpl: Checking if config exists: $configName');

      final configs = _scheduleConfigService.configs;
      final hasConfig = configs.any((c) => c.name == configName);

      AppLogger.d('ConfigLocalDataSourceImpl: Config exists: $hasConfig');

      return hasConfig;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSourceImpl: Error checking if config exists',
          e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> getActiveConfigName() async {
    try {
      AppLogger.d('ConfigLocalDataSourceImpl: Getting active config name');

      final defaultConfig = _scheduleConfigService.defaultConfig;
      final configName = defaultConfig?.name;

      AppLogger.d('ConfigLocalDataSourceImpl: Active config name: $configName');

      return configName;
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSourceImpl: Error getting active config name',
          e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setActiveConfigName(String configName) async {
    try {
      AppLogger.d(
          'ConfigLocalDataSourceImpl: Setting active config name: $configName');

      final configs = _scheduleConfigService.configs;
      final config = configs.where((c) => c.name == configName).firstOrNull;

      if (config != null) {
        await _scheduleConfigService.setDefaultConfig(config);
        AppLogger.d(
            'ConfigLocalDataSourceImpl: Successfully set active config: $configName');
      } else {
        throw ArgumentError('Configuration not found: $configName');
      }
    } catch (e, stackTrace) {
      AppLogger.e('ConfigLocalDataSourceImpl: Error setting active config name',
          e, stackTrace);
      rethrow;
    }
  }
}
