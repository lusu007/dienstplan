import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class SettingsLocalDataSource {
  final DatabaseService _databaseService;

  SettingsLocalDataSource(this._databaseService);

  /// Get settings from local storage
  Future<Settings?> getSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSource: Getting settings');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.d('SettingsLocalDataSource: No settings found');
        return null;
      }

      final settings = Settings.fromMap(maps.first);
      AppLogger.d('SettingsLocalDataSource: Retrieved settings');

      return settings;
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSource: Error getting settings', e, stackTrace);
      rethrow;
    }
  }

  /// Save settings to local storage
  Future<void> saveSettings(Settings settings) async {
    try {
      AppLogger.d('SettingsLocalDataSource: Saving settings');

      final db = await _databaseService.database;

      // Clear existing settings and insert new ones
      await db.transaction((txn) async {
        await txn.delete('settings');
        await txn.insert(
          'settings',
          settings.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      AppLogger.d('SettingsLocalDataSource: Successfully saved settings');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSource: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  /// Delete settings from local storage
  Future<void> deleteSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSource: Deleting settings');

      final db = await _databaseService.database;
      await db.delete('settings');

      AppLogger.d('SettingsLocalDataSource: Successfully deleted settings');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSource: Error deleting settings', e, stackTrace);
      rethrow;
    }
  }

  /// Check if settings exist
  Future<bool> hasSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSource: Checking if settings exist');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        limit: 1,
      );

      final hasSettings = maps.isNotEmpty;
      AppLogger.d('SettingsLocalDataSource: Settings exist: $hasSettings');

      return hasSettings;
    } catch (e, stackTrace) {
      AppLogger.e('SettingsLocalDataSource: Error checking if settings exist',
          e, stackTrace);
      rethrow;
    }
  }

  /// Get a specific setting value by key
  Future<String?> getSettingValue(String key) async {
    try {
      AppLogger.d(
          'SettingsLocalDataSource: Getting setting value for key: $key');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        columns: [key],
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.d('SettingsLocalDataSource: No settings found for key: $key');
        return null;
      }

      final value = maps.first[key] as String?;
      AppLogger.d(
          'SettingsLocalDataSource: Retrieved value for key $key: $value');

      return value;
    } catch (e, stackTrace) {
      AppLogger.e('SettingsLocalDataSource: Error getting setting value', e,
          stackTrace);
      rethrow;
    }
  }

  /// Set a specific setting value by key
  Future<void> setSettingValue(String key, String value) async {
    try {
      AppLogger.d(
          'SettingsLocalDataSource: Setting value for key: $key = $value');

      final db = await _databaseService.database;

      // Check if settings exist
      final hasSettings = await this.hasSettings();

      if (hasSettings) {
        // Update existing settings
        await db.update(
          'settings',
          {key: value},
          where: '1=1', // Update the first (and only) row
        );
      } else {
        // Create new settings with default values and the specified key-value
        final defaultSettings = Settings(
          calendarFormat: CalendarFormat.month,
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
        );
        final settingsMap = defaultSettings.toMap();
        settingsMap[key] = value;

        await db.insert(
          'settings',
          settingsMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      AppLogger.d(
          'SettingsLocalDataSource: Successfully set value for key: $key');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSource: Error setting value', e, stackTrace);
      rethrow;
    }
  }
}
