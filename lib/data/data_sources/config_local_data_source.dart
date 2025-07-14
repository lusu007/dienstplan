import 'package:dienstplan/data/models/duty_schedule_config.dart';

abstract class ConfigLocalDataSource {
  /// Get all configurations from local storage
  Future<List<DutyScheduleConfig>> getConfigs();

  /// Get a specific configuration by name
  Future<DutyScheduleConfig?> getConfig(String configName);

  /// Save a configuration to local storage
  Future<void> saveConfig(DutyScheduleConfig config);

  /// Save multiple configurations to local storage
  Future<void> saveConfigs(List<DutyScheduleConfig> configs);

  /// Delete a configuration by name
  Future<void> deleteConfig(String configName);

  /// Clear all configurations
  Future<void> clearConfigs();

  /// Check if a configuration exists
  Future<bool> hasConfig(String configName);

  /// Get the active configuration name
  Future<String?> getActiveConfigName();

  /// Set the active configuration name
  Future<void> setActiveConfigName(String configName);
}
