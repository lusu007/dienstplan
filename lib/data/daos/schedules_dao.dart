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
        whereClause += ' AND date_ymd >= ?';
        whereArgs.add(ScheduleKeyHelper.formatDateYmd(startDate));
      }

      if (endDate != null) {
        whereClause += ' AND date_ymd <= ?';
        whereArgs.add(ScheduleKeyHelper.formatDateYmd(endDate));
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date_ymd ASC, service ASC',
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

      // Use date_ymd for better index utilization when possible
      String whereClause = 'date_ymd BETWEEN ? AND ?';
      final List<Object?> whereArgs = <Object?>[
        ScheduleKeyHelper.formatDateYmd(startDate),
        ScheduleKeyHelper.formatDateYmd(endDate),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date_ymd ASC, service ASC',
      );

      return rows
          .map((Map<String, Object?> m) => data_model.Schedule.fromMap(m))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesDao: Error loading schedules for range',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> saveSchedules(List<data_model.Schedule> schedules) async {
    if (schedules.isEmpty) {
      return;
    }
    try {
      AppLogger.i(
        'SchedulesDao: Saving ${schedules.length} schedules in chunks',
      );
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
            batch.insert(
              'schedules',
              values,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
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

  /// Optimized query for schedules on a specific day using date_ymd index
  Future<List<data_model.Schedule>> loadSchedulesForDay({
    required DateTime day,
    String? configName,
  }) async {
    try {
      AppLogger.i('SchedulesDao: Loading schedules for specific day');
      final Database db = await _databaseService.database;

      String whereClause = 'date_ymd = ?';
      final List<Object?> whereArgs = <Object?>[
        ScheduleKeyHelper.formatDateYmd(day),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'service ASC',
      );

      return rows
          .map((Map<String, Object?> m) => data_model.Schedule.fromMap(m))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesDao: Error loading schedules for day',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Optimized query for schedules in a specific month using date_ymd index
  Future<List<data_model.Schedule>> loadSchedulesForMonth({
    required DateTime month,
    String? configName,
  }) async {
    try {
      AppLogger.i('SchedulesDao: Loading schedules for specific month');
      final Database db = await _databaseService.database;

      // Format month start and end for precise matching
      final DateTime monthStart = DateTime(month.year, month.month, 1);
      final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);

      String whereClause = 'date_ymd >= ? AND date_ymd <= ?';
      final List<Object?> whereArgs = <Object?>[
        ScheduleKeyHelper.formatDateYmd(monthStart),
        ScheduleKeyHelper.formatDateYmd(monthEnd),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final List<Map<String, Object?>> rows = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date_ymd ASC, service ASC',
      );

      return rows
          .map((Map<String, Object?> m) => data_model.Schedule.fromMap(m))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesDao: Error loading schedules for month',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Count schedules for a specific month (useful for coverage checks)
  Future<int> countSchedulesForMonth({
    required DateTime month,
    String? configName,
  }) async {
    try {
      final Database db = await _databaseService.database;

      final DateTime monthStart = DateTime(month.year, month.month, 1);
      final DateTime monthEnd = DateTime(month.year, month.month + 1, 0);

      String whereClause = 'date_ymd >= ? AND date_ymd <= ?';
      final List<Object?> whereArgs = <Object?>[
        ScheduleKeyHelper.formatDateYmd(monthStart),
        ScheduleKeyHelper.formatDateYmd(monthEnd),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM schedules WHERE $whereClause',
        whereArgs,
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesDao: Error counting schedules for month',
        e,
        stackTrace,
      );
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

  /// Delete all schedules for a specific config
  Future<void> deleteSchedulesByConfigName(String configName) async {
    try {
      AppLogger.i('SchedulesDao: Deleting schedules for config: $configName');
      final Database db = await _databaseService.database;
      final int deletedCount = await db.delete(
        'schedules',
        where: 'config_name = ?',
        whereArgs: <Object?>[configName],
      );
      AppLogger.i(
        'SchedulesDao: Deleted $deletedCount schedules for config: $configName',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesDao: Error deleting schedules for config',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
