import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/schedule.dart' as data_model;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/utils/schedule_key_helper.dart';
import 'package:sqflite/sqflite.dart';

class SchedulesDao {
  static const int _defaultLimit = 1000;
  static const int _batchSize = 1000;

  final DatabaseService _databaseService;

  SchedulesDao(this._databaseService);

  Future<List<data_model.Schedule>> loadSchedules({
    int limit = _defaultLimit,
    int offset = 0,
    String? configName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.i('SchedulesDao: Loading schedules');
      final Database db = await _databaseService.database;

      String whereClause = '1=1';
      final List<Object?> whereArgs = <Object?>[];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      if (startDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, service ASC',
        limit: limit,
        offset: offset,
      );

      return rows
          .map((Map<String, Object?> m) => data_model.Schedule.fromMap(m))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('SchedulesDao: Error loading schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<List<data_model.Schedule>> loadSchedulesForRange({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async {
    try {
      AppLogger.i('SchedulesDao: Loading schedules for range');
      final Database db = await _databaseService.database;

      String whereClause = 'date BETWEEN ? AND ?';
      final List<Object?> whereArgs = <Object?>[
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, service ASC',
      );

      return rows
          .map((Map<String, Object?> m) => data_model.Schedule.fromMap(m))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(
          'SchedulesDao: Error loading schedules for range', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveSchedules(List<data_model.Schedule> schedules) async {
    if (schedules.isEmpty) {
      return;
    }
    try {
      AppLogger.i(
          'SchedulesDao: Saving ${schedules.length} schedules in chunks');
      final Database db = await _databaseService.database;
      final int now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction((Transaction txn) async {
        for (int i = 0; i < schedules.length; i += _batchSize) {
          final int end = (i + _batchSize < schedules.length)
              ? i + _batchSize
              : schedules.length;
          final List<data_model.Schedule> current = schedules.sublist(i, end);
          final Batch batch = txn.batch();
          for (final data_model.Schedule s in current) {
            final String ymd = ScheduleKeyHelper.formatDateYmd(s.date);
            final Map<String, Object?> values = <String, Object?>{
              'date': s.date.toIso8601String(),
              'date_ymd': ymd,
              'service': s.service,
              'duty_group_id': s.dutyGroupId,
              'duty_group_name': s.dutyGroupName,
              'duty_type_id': s.dutyTypeId,
              'is_all_day': s.isAllDay ? 1 : 0,
              'config_name': s.configName,
              'created_at': now,
              'updated_at': now,
            };
            batch.insert('schedules', values,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        }
      });

      AppLogger.i('SchedulesDao: Saved schedules');
    } catch (e, stackTrace) {
      AppLogger.e('SchedulesDao: Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteByCompositeId(String id) async {
    try {
      AppLogger.i('SchedulesDao: Deleting schedule by composite id');
      final Database db = await _databaseService.database;
      final ScheduleKeyParts parts = ScheduleKeyHelper.parseScheduleId(id);
      await db.delete(
        'schedules',
        where:
            'date_ymd = ? AND config_name = ? AND duty_group_id = ? AND duty_type_id = ? AND service = ?',
        whereArgs: <Object?>[
          parts.dateYmd,
          parts.configName,
          parts.dutyGroupId,
          parts.dutyTypeId,
          parts.service,
        ],
      );
      AppLogger.i('SchedulesDao: Deleted schedule');
    } catch (e, stackTrace) {
      AppLogger.e('SchedulesDao: Error deleting schedule', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      AppLogger.i('SchedulesDao: Clearing schedules');
      final Database db = await _databaseService.database;
      await db.delete('schedules');
    } catch (e, stackTrace) {
      AppLogger.e('SchedulesDao: Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }
}
