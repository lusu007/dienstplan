import 'package:sqflite/sqflite.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/school_holiday.dart';

class SchoolHolidaysDao {
  final DatabaseService _databaseService;

  SchoolHolidaysDao(this._databaseService);

  /// Get holidays for a specific state and year
  Future<List<SchoolHoliday>> getHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      AppLogger.d('SchoolHolidaysDao: Getting holidays for $stateCode, year $year');
      
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'school_holidays',
        where: 'state_code = ? AND year = ?',
        whereArgs: [stateCode, year],
        orderBy: 'start_date ASC',
      );

      final holidays = maps.map((map) => SchoolHoliday.fromMap(map)).toList();
      AppLogger.d('SchoolHolidaysDao: Retrieved ${holidays.length} holidays');
      return holidays;
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error getting holidays', e, stackTrace);
      rethrow;
    }
  }

  /// Get holidays within a date range
  Future<List<SchoolHoliday>> getHolidaysInRange({
    required String stateCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d('SchoolHolidaysDao: Getting holidays in range $startDate to $endDate for $stateCode');
      
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'school_holidays',
        where: 'state_code = ? AND start_date <= ? AND end_date >= ?',
        whereArgs: [
          stateCode,
          endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
          startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
        ],
        orderBy: 'start_date ASC',
      );

      final holidays = maps.map((map) => SchoolHoliday.fromMap(map)).toList();
      AppLogger.d('SchoolHolidaysDao: Retrieved ${holidays.length} holidays in range');
      return holidays;
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error getting holidays in range', e, stackTrace);
      rethrow;
    }
  }

  /// Save holidays to database
  Future<void> saveHolidays({
    required String stateCode,
    required int year,
    required List<SchoolHoliday> holidays,
  }) async {
    try {
      AppLogger.d('SchoolHolidaysDao: Saving ${holidays.length} holidays for $stateCode, year $year');
      
      final db = await _databaseService.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction((txn) async {
        // Delete existing holidays for this state and year
        await txn.delete(
          'school_holidays',
          where: 'state_code = ? AND year = ?',
          whereArgs: [stateCode, year],
        );

        // Insert new holidays
        for (final holiday in holidays) {
          await txn.insert(
            'school_holidays',
            {
              ...holiday.toMap(),
              'created_at': now,
              'updated_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      AppLogger.d('SchoolHolidaysDao: Successfully saved ${holidays.length} holidays');
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error saving holidays', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all holidays
  Future<void> clearAllHolidays() async {
    try {
      AppLogger.d('SchoolHolidaysDao: Clearing all holidays');
      
      final db = await _databaseService.database;
      await db.delete('school_holidays');
      
      AppLogger.d('SchoolHolidaysDao: Successfully cleared all holidays');
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error clearing holidays', e, stackTrace);
      rethrow;
    }
  }

  /// Clear holidays for a specific state and year
  Future<void> clearHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      AppLogger.d('SchoolHolidaysDao: Clearing holidays for $stateCode, year $year');
      
      final db = await _databaseService.database;
      await db.delete(
        'school_holidays',
        where: 'state_code = ? AND year = ?',
        whereArgs: [stateCode, year],
      );
      
      AppLogger.d('SchoolHolidaysDao: Successfully cleared holidays');
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error clearing holidays', e, stackTrace);
      rethrow;
    }
  }

  /// Get the last update timestamp for holidays
  Future<DateTime?> getLastUpdateTime({
    required String stateCode,
    required int year,
  }) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'school_holidays',
        columns: ['updated_at'],
        where: 'state_code = ? AND year = ?',
        whereArgs: [stateCode, year],
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final timestamp = maps.first['updated_at'] as int;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.e('SchoolHolidaysDao: Error getting last update time', e, stackTrace);
      return null;
    }
  }
}
