import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/settings.dart' as data_model;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class SettingsDao {
  final DatabaseService _databaseService;

  SettingsDao(this._databaseService);

  Future<data_model.Settings?> load() async {
    try {
      AppLogger.i('SettingsDao: Loading settings');
      final Database db = await _databaseService.database;
      final List<Map<String, Object?>> rows = await db.query(
        'settings',
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return data_model.Settings.fromMap(rows.first);
    } catch (e, stackTrace) {
      AppLogger.e('SettingsDao: Error loading settings', e, stackTrace);
      rethrow;
    }
  }

  Future<void> save(data_model.Settings settings) async {
    try {
      AppLogger.i('SettingsDao: Saving settings');
      final Database db = await _databaseService.database;
      final int now = DateTime.now().millisecondsSinceEpoch;
      final Map<String, Object?> values = settings.toMap()
        ..addAll(<String, Object?>{'created_at': now, 'updated_at': now});
      await db.transaction((Transaction txn) async {
        await txn.delete('settings');
        await txn.insert(
          'settings',
          values,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } catch (e, stackTrace) {
      AppLogger.e('SettingsDao: Error saving settings', e, stackTrace);

      // If it's a missing column error, log it but don't crash
      if (e.toString().contains('my_accent_color') &&
          e.toString().contains('no column named')) {
        AppLogger.w(
          'SettingsDao: my_accent_color column missing - this should be fixed by migration',
        );
        // Don't rethrow - let the app continue without saving this setting
        return;
      }

      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      AppLogger.i('SettingsDao: Clearing settings');
      final Database db = await _databaseService.database;
      await db.delete('settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsDao: Error clearing settings', e, stackTrace);
      rethrow;
    }
  }
}
