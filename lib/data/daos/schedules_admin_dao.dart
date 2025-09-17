import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/core/utils/logger.dart';

class SchedulesAdminDao {
  final DatabaseService _databaseService;

  SchedulesAdminDao(this._databaseService);

  Future<void> clearSchedules() async {
    try {
      AppLogger.i('SchedulesAdminDao: Clearing schedules');
      final db = await _databaseService.database;
      await db.delete('schedules');
    } catch (e, stackTrace) {
      AppLogger.e('SchedulesAdminDao: Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearDutySchedule(String configName) async {
    try {
      AppLogger.i('SchedulesAdminDao: Clearing duty schedule for $configName');
      final db = await _databaseService.database;
      await db.delete(
        'schedules',
        where: 'config_name = ?',
        whereArgs: <Object?>[configName],
      );
      await db.delete(
        'duty_types',
        where: 'config_name = ?',
        whereArgs: <Object?>[configName],
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'SchedulesAdminDao: Error clearing duty schedule',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
