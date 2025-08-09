import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/data/models/schedule.dart' as data_model;
import 'package:dienstplan/data/models/mappers/schedule_mapper.dart' as mapper;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleLocalDataSource {
  final DatabaseService _databaseService;

  ScheduleLocalDataSource(this._databaseService);

  /// Get all schedules from local storage
  Future<List<Schedule>> getSchedules() async {
    try {
      AppLogger.d('ScheduleLocalDataSource: Getting all schedules');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        orderBy: 'date ASC, duty_group_name ASC',
      );

      final schedules =
          maps.map((map) => data_model.Schedule.fromMap(map)).toList();
      AppLogger.d(
          'ScheduleLocalDataSource: Retrieved ${schedules.length} schedules');

      return schedules.map(mapper.toDomainSchedule).toList();
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error getting schedules', e, stackTrace);
      rethrow;
    }
  }

  /// Get schedules for a specific date range
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Getting schedules for date range: $startDate to $endDate');

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
          'ScheduleLocalDataSource: Retrieved ${schedules.length} schedules for date range');

      return schedules.map(mapper.toDomainSchedule).toList();
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error getting schedules for date range',
          e,
          stackTrace);
      rethrow;
    }
  }

  /// Save schedules to local storage
  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Saving ${schedules.length} schedules');

      final db = await _databaseService.database;

      // Use batch operations for better performance
      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final schedule in schedules) {
          final dataModel = mapper.toDataSchedule(schedule);
          batch.insert(
            'schedules',
            dataModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
      });

      AppLogger.d(
          'ScheduleLocalDataSource: Successfully saved ${schedules.length} schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  /// Save a single schedule to local storage
  Future<void> saveSchedule(Schedule schedule) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Saving single schedule for ${schedule.date}');

      final db = await _databaseService.database;
      final dataModel = mapper.toDataSchedule(schedule);

      await db.insert(
        'schedules',
        dataModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger.d(
          'ScheduleLocalDataSource: Successfully saved single schedule');
    } catch (e, stackTrace) {
      AppLogger.e('ScheduleLocalDataSource: Error saving single schedule', e,
          stackTrace);
      rethrow;
    }
  }

  /// Clear all schedules from local storage
  Future<void> clearSchedules() async {
    try {
      AppLogger.d('ScheduleLocalDataSource: Clearing all schedules');

      final db = await _databaseService.database;
      await db.delete('schedules');

      AppLogger.d(
          'ScheduleLocalDataSource: Successfully cleared all schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }

  /// Delete schedules for a specific date range
  Future<void> deleteSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Deleting schedules for date range: $startDate to $endDate');

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
          'ScheduleLocalDataSource: Successfully deleted $deletedRows schedules');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error deleting schedules for date range',
          e,
          stackTrace);
      rethrow;
    }
  }

  /// Get duty types for a specific configuration
  Future<List<String>> getDutyTypes({required String configName}) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Getting duty types for config: $configName');

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
          'ScheduleLocalDataSource: Retrieved ${dutyTypes.length} duty types');

      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error getting duty types', e, stackTrace);
      rethrow;
    }
  }

  /// Get duty groups for a specific configuration
  Future<List<String>> getDutyGroups({required String configName}) async {
    try {
      AppLogger.d(
          'ScheduleLocalDataSource: Getting duty groups for config: $configName');

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
          'ScheduleLocalDataSource: Retrieved ${dutyGroups.length} duty groups');

      return dutyGroups;
    } catch (e, stackTrace) {
      AppLogger.e(
          'ScheduleLocalDataSource: Error getting duty groups', e, stackTrace);
      rethrow;
    }
  }
}
