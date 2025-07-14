import 'package:dienstplan/data/data_sources/settings_local_data_source.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final DatabaseService _databaseService;

  SettingsLocalDataSourceImpl(this._databaseService);

  @override
  Future<Settings?> getSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSourceImpl: Getting settings');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.d('SettingsLocalDataSourceImpl: No settings found');
        return null;
      }

      final settings = Settings.fromMap(maps.first);
      AppLogger.d('SettingsLocalDataSourceImpl: Retrieved settings');

      return settings;
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSourceImpl: Error getting settings', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    try {
      AppLogger.d('SettingsLocalDataSourceImpl: Saving settings');

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

      AppLogger.d('SettingsLocalDataSourceImpl: Successfully saved settings');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSourceImpl: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSourceImpl: Deleting settings');

      final db = await _databaseService.database;
      await db.delete('settings');

      AppLogger.d('SettingsLocalDataSourceImpl: Successfully deleted settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsLocalDataSourceImpl: Error deleting settings', e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> hasSettings() async {
    try {
      AppLogger.d('SettingsLocalDataSourceImpl: Checking if settings exist');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        limit: 1,
      );

      final hasSettings = maps.isNotEmpty;
      AppLogger.d('SettingsLocalDataSourceImpl: Settings exist: $hasSettings');

      return hasSettings;
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSourceImpl: Error checking if settings exist',
          e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<String?> getSettingValue(String key) async {
    try {
      AppLogger.d(
          'SettingsLocalDataSourceImpl: Getting setting value for key: $key');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        columns: [key],
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.d(
            'SettingsLocalDataSourceImpl: No settings found for key: $key');
        return null;
      }

      final value = maps.first[key] as String?;
      AppLogger.d(
          'SettingsLocalDataSourceImpl: Retrieved value for key $key: $value');

      return value;
    } catch (e, stackTrace) {
      AppLogger.e('SettingsLocalDataSourceImpl: Error getting setting value', e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> setSettingValue(String key, String value) async {
    try {
      AppLogger.d(
          'SettingsLocalDataSourceImpl: Setting value for key: $key = $value');

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
          'SettingsLocalDataSourceImpl: Successfully set value for key: $key');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsLocalDataSourceImpl: Error setting value', e, stackTrace);
      rethrow;
    }
  }
}
