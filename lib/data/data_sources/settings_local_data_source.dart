import 'package:dienstplan/domain/entities/settings.dart';

abstract class SettingsLocalDataSource {
  /// Get settings from local storage
  Future<Settings?> getSettings();

  /// Save settings to local storage
  Future<void> saveSettings(Settings settings);

  /// Delete settings from local storage
  Future<void> deleteSettings();

  /// Check if settings exist
  Future<bool> hasSettings();

  /// Get a specific setting value by key
  Future<String?> getSettingValue(String key);

  /// Set a specific setting value by key
  Future<void> setSettingValue(String key, String value);
}
