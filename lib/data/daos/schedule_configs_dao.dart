import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class ScheduleConfigsDao {
  final DatabaseService _databaseService;

  ScheduleConfigsDao(this._databaseService);

  Future<void> saveScheduleConfig({
    required String name,
    required String version,
    required String displayName,
    String? description,
    String? policeAuthority,
    String? icon,
    required DateTime startDate,
    required String startWeekDay,
    required List<String> days,
  }) async {
    try {
      AppLogger.i('ScheduleConfigsDao: Saving schedule config $name');
      final Database db = await _databaseService.database;
      final int now = DateTime.now().millisecondsSinceEpoch;

      await db.insert('schedule_configs', {
        'name': name,
        'version': version,
        'display_name': displayName,
        'description': description,
        'police_authority': policeAuthority,
        'icon': icon,
        'start_date': startDate.toIso8601String(),
        'start_week_day': startWeekDay,
        'days': jsonEncode(days),
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      AppLogger.i('ScheduleConfigsDao: Saved schedule config $name');
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleConfigsDao: Error saving schedule config',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllScheduleConfigs() async {
    try {
      AppLogger.i('ScheduleConfigsDao: Loading all schedule configs');
      final Database db = await _databaseService.database;

      final List<Map<String, Object?>> rows = await db.query(
        'schedule_configs',
        orderBy: 'display_name ASC',
      );

      final configs = rows.map((row) {
        return {
          'name': row['name'] as String,
          'version': row['version'] as String,
          'display_name': row['display_name'] as String,
          'description': row['description'] as String?,
          'police_authority': row['police_authority'] as String?,
          'icon': row['icon'] as String?,
          'start_date': row['start_date'] as String,
          'start_week_day': row['start_week_day'] as String,
          'days': jsonDecode(row['days'] as String) as List<dynamic>,
        };
      }).toList();

      AppLogger.i(
        'ScheduleConfigsDao: Loaded ${configs.length} schedule configs',
      );
      return configs;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleConfigsDao: Error loading schedule configs',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getScheduleConfigByName(String name) async {
    try {
      AppLogger.i('ScheduleConfigsDao: Loading schedule config $name');
      final Database db = await _databaseService.database;

      final List<Map<String, Object?>> rows = await db.query(
        'schedule_configs',
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );

      if (rows.isEmpty) {
        AppLogger.i('ScheduleConfigsDao: No schedule config found for $name');
        return null;
      }

      final row = rows.first;
      final config = {
        'name': row['name'] as String,
        'version': row['version'] as String,
        'display_name': row['display_name'] as String,
        'description': row['description'] as String?,
        'police_authority': row['police_authority'] as String?,
        'icon': row['icon'] as String?,
        'start_date': row['start_date'] as String,
        'start_week_day': row['start_week_day'] as String,
        'days': jsonDecode(row['days'] as String) as List<dynamic>,
      };

      AppLogger.i('ScheduleConfigsDao: Loaded schedule config $name');
      return config;
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleConfigsDao: Error loading schedule config $name',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteScheduleConfig(String name) async {
    try {
      AppLogger.i('ScheduleConfigsDao: Deleting schedule config $name');
      final Database db = await _databaseService.database;

      await db.delete('schedule_configs', where: 'name = ?', whereArgs: [name]);

      AppLogger.i('ScheduleConfigsDao: Deleted schedule config $name');
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleConfigsDao: Error deleting schedule config $name',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> clearAllScheduleConfigs() async {
    try {
      AppLogger.i('ScheduleConfigsDao: Clearing all schedule configs');
      final Database db = await _databaseService.database;

      await db.delete('schedule_configs');

      AppLogger.i('ScheduleConfigsDao: Cleared all schedule configs');
    } catch (e, stackTrace) {
      AppLogger.e(
        'ScheduleConfigsDao: Error clearing schedule configs',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
