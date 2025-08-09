import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class MaintenanceDao {
  final DatabaseService _databaseService;

  MaintenanceDao(this._databaseService);

  Future<void> optimizeDatabase() async {
    try {
      AppLogger.i('MaintenanceDao: Optimizing database');
      final db = await _databaseService.database;
      await db.execute('ANALYZE');
      await db.execute('VACUUM');
      AppLogger.i('MaintenanceDao: Optimization completed');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error optimizing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    try {
      AppLogger.i(
          'MaintenanceDao: Cleaning up data older than $daysToKeep days');
      final db = await _databaseService.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      // Use date_ymd for better index utilization
      final cutoffYmd = _formatDateYmd(cutoffDate);
      final deleted = await db.delete(
        'schedules',
        where: 'date_ymd < ?',
        whereArgs: <Object?>[cutoffYmd],
      );
      AppLogger.i('MaintenanceDao: Deleted $deleted old schedules');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error cleaning up old data', e, stackTrace);
      rethrow;
    }
  }

  String _formatDateYmd(DateTime date) {
    final DateTime utc = date.toUtc();
    final String y = utc.year.toString().padLeft(4, '0');
    final String m = utc.month.toString().padLeft(2, '0');
    final String d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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
      final bool result = (schedulesCount ?? 0) > 0 || (settingsCount ?? 0) > 0;
      AppLogger.i('MaintenanceDao: hasData = $result');
      return result;
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error checking hasData', e, stackTrace);
      return false;
    }
  }

  Future<void> clearAllData() async {
    try {
      AppLogger.i('MaintenanceDao: Clearing all tables');
      final db = await _databaseService.database;
      await db.delete('schedules');
      await db.delete('duty_types');
      await db.delete('settings');
      AppLogger.i('MaintenanceDao: Cleared all tables');
    } catch (e, stackTrace) {
      AppLogger.e('MaintenanceDao: Error clearing all data', e, stackTrace);
      rethrow;
    }
  }
}
