import 'package:dienstplan/core/utils/schedule_key_helper.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class MaintenanceDao {
  final DatabaseService _databaseService;

  MaintenanceDao(this._databaseService);

  Future<void> optimizeDatabase() async {
    try {
      AppLogger.d('MaintenanceDao: Optimizing database');
      final db = await _databaseService.database;
      await db.execute('ANALYZE');
      await db.execute('VACUUM');
      AppLogger.d('MaintenanceDao: Optimization completed');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error optimizing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    try {
      AppLogger.d(
        'MaintenanceDao: Cleaning up data older than $daysToKeep days',
      );
      final db = await _databaseService.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      // Use date_ymd for better index utilization
      final cutoffYmd = ScheduleKeyHelper.formatDateYmd(cutoffDate);
      final deleted = await db.delete(
        'schedules',
        where: 'date_ymd < ?',
        whereArgs: <Object?>[cutoffYmd],
      );
      AppLogger.d('MaintenanceDao: Deleted $deleted old schedules');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error cleaning up old data', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> hasData() async {
    try {
      final db = await _databaseService.database;
      final int? schedulesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM schedules'),
      );
      final int? settingsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM settings'),
      );
      final int? holidaysCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM school_holidays'),
      );
      final int? configsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM schedule_configs'),
      );
      final bool result =
          (schedulesCount ?? 0) > 0 ||
          (settingsCount ?? 0) > 0 ||
          (holidaysCount ?? 0) > 0 ||
          (configsCount ?? 0) > 0;
      AppLogger.d('MaintenanceDao: hasData = $result');
      return result;
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error checking hasData', e, stackTrace);
      return false;
    }
  }

  Future<void> clearAllData() async {
    try {
      AppLogger.d('MaintenanceDao: Clearing all tables');
      final db = await _databaseService.database;
      await db.delete('schedules');
      await db.delete('duty_types');
      await db.delete('settings');
      await db.delete('school_holidays');
      await db.delete('schedule_configs');
      AppLogger.d('MaintenanceDao: Cleared all tables');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error clearing all data', e, stackTrace);
      rethrow;
    }
  }
}
