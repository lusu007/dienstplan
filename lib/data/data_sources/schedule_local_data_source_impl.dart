import 'package:dienstplan/data/data_sources/schedule_local_data_source.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/data/models/schedule.dart' as data_model;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final DatabaseService _databaseService;

  ScheduleLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      AppLogger.d('ScheduleLocalDataSourceImpl: Getting all schedules');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        orderBy: 'date ASC, duty_group_name ASC',
      );

      final schedules =
          maps.map((map) => data_model.Schedule.fromMap(map)).toList();
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Retrieved ${schedules.length} schedules');

      return schedules.map((s) => s.toDomain()).toList();
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSourceImpl: Error getting schedules', e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Getting schedules for date range: $startDate to $endDate');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'date ASC, duty_group_name ASC',
      );

      final schedules =
          maps.map((map) => data_model.Schedule.fromMap(map)).toList();
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Retrieved ${schedules.length} schedules for date range');

      return schedules.map((s) => s.toDomain()).toList();
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSourceImpl: Error getting schedules for date range',
          e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Saving ${schedules.length} schedules');

      final db = await _databaseService.database;

      // Use batch operations for better performance
      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final schedule in schedules) {
          final dataModel = data_model.Schedule.fromDomain(schedule);
          batch.insert(
            'schedules',
            dataModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
      });

      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Successfully saved ${schedules.length} schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSourceImpl: Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Saving single schedule for ${schedule.date}');

      final db = await _databaseService.database;
      final dataModel = data_model.Schedule.fromDomain(schedule);

      await db.insert(
        'schedules',
        dataModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Successfully saved single schedule');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSourceImpl: Error saving single schedule',
          e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearSchedules() async {
    try {
      AppLogger.d('ScheduleLocalDataSourceImpl: Clearing all schedules');

      final db = await _databaseService.database;
      await db.delete('schedules');

      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Successfully cleared all schedules');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSourceImpl: Error clearing schedules', e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Deleting schedules for date range: $startDate to $endDate');

      final db = await _databaseService.database;
      final deletedRows = await db.delete(
        'schedules',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
      );

      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Successfully deleted $deletedRows schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSourceImpl: Error deleting schedules for date range',
          e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<String>> getDutyTypes({required String configName}) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Getting duty types for config: $configName');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        distinct: true,
        columns: ['service'],
        where: 'config_name = ?',
        whereArgs: [configName],
        orderBy: 'service ASC',
      );

      final dutyTypes = maps.map((map) => map['service'] as String).toList();
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Retrieved ${dutyTypes.length} duty types');

      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSourceImpl: Error getting duty types', e,
          stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<String>> getDutyGroups({required String configName}) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Getting duty groups for config: $configName');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        distinct: true,
        columns: ['duty_group_name'],
        where: 'config_name = ? AND duty_group_name IS NOT NULL',
        whereArgs: [configName],
        orderBy: 'duty_group_name ASC',
      );

      final dutyGroups =
          maps.map((map) => map['duty_group_name'] as String).toList();
      AppLogger.d(
          'ScheduleLocalDataSourceImpl: Retrieved ${dutyGroups.length} duty groups');

      return dutyGroups;
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSourceImpl: Error getting duty groups', e,
          stackTrace);
      rethrow;
    }
  }
}
