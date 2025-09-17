import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/duty_type.dart' as data_model;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:sqflite/sqflite.dart';

class DutyTypesDao {
  final DatabaseService _databaseService;

  DutyTypesDao(this._databaseService);

  Future<void> replaceAllForConfig(
    String configName,
    Map<String, data_model.DutyType> dutyTypes,
  ) async {
    try {
      AppLogger.i('DutyTypesDao: Replacing duty types for $configName');
      final Database db = await _databaseService.database;
      final int now = DateTime.now().millisecondsSinceEpoch;
      await db.transaction((Transaction txn) async {
        await txn.delete(
          'duty_types',
          where: 'config_name = ?',
          whereArgs: <Object?>[configName],
        );
        final Batch batch = txn.batch();
        dutyTypes.forEach((String id, data_model.DutyType dt) {
          batch.insert('duty_types', <String, Object?>{
            'config_name': configName,
            'id': id,
            'label': dt.label,
            'all_day': dt.isAllDay ? 1 : 0,
            'icon': dt.icon,
            'created_at': now,
            'updated_at': now,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
      });
    } catch (e, stackTrace) {
      AppLogger.e('DutyTypesDao: Error replacing duty types', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, data_model.DutyType>> loadForConfig(
    String configName,
  ) async {
    try {
      AppLogger.i('DutyTypesDao: Loading duty types for $configName');
      final Database db = await _databaseService.database;
      final List<Map<String, Object?>> rows = await db.query(
        'duty_types',
        where: 'config_name = ?',
        whereArgs: <Object?>[configName],
      );
      final Map<String, data_model.DutyType> result =
          <String, data_model.DutyType>{};
      for (final Map<String, Object?> m in rows) {
        result[m['id']! as String] = data_model.DutyType.fromMap(m);
      }
      return result;
    } catch (e, stackTrace) {
      AppLogger.e('DutyTypesDao: Error loading duty types', e, stackTrace);
      rethrow;
    }
  }
}
