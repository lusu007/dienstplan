import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/utils/schedule_key_helper.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:sqflite/sqflite.dart';

class PersonalCalendarEntriesDao {
  final DatabaseService _databaseService;

  PersonalCalendarEntriesDao(this._databaseService);

  Future<List<PersonalCalendarEntry>> loadBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Database db = await _databaseService.database;
      final String startYmd = ScheduleKeyHelper.formatDateYmd(startDate);
      final String endYmd = ScheduleKeyHelper.formatDateYmd(endDate);
      final List<Map<String, Object?>> rows = await db.query(
        'personal_calendar_entries',
        where: 'date_ymd BETWEEN ? AND ?',
        whereArgs: <Object?>[startYmd, endYmd],
        orderBy: 'date_ymd ASC, start_minutes ASC, title ASC',
      );
      return rows.map(_rowToEntry).toList(growable: false);
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarEntriesDao: loadBetween failed',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> upsert(PersonalCalendarEntry entry) async {
    try {
      final Database db = await _databaseService.database;
      final String ymd = ScheduleKeyHelper.formatDateYmd(entry.date);
      await db.insert(
        'personal_calendar_entries',
        <String, Object?>{
          'id': entry.id,
          'kind': entry.kind.toStorage(),
          'title': entry.title,
          'notes': entry.notes,
          'date_ymd': ymd,
          'is_all_day': entry.isAllDay ? 1 : 0,
          'start_minutes': entry.startMinutesFromMidnight,
          'end_minutes': entry.endMinutesFromMidnight,
          'duty_group_name': entry.dutyGroupName,
          'created_at': entry.createdAtMs,
          'updated_at': entry.updatedAtMs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarEntriesDao: upsert failed (id=${entry.id})',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteById(String id) async {
    try {
      final Database db = await _databaseService.database;
      await db.delete(
        'personal_calendar_entries',
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarEntriesDao: deleteById failed (id=$id)',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  PersonalCalendarEntry _rowToEntry(Map<String, Object?> m) {
    final String ymd = m['date_ymd']! as String;
    final List<String> parts = ymd.split('-');
    final DateTime date = DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return PersonalCalendarEntry(
      id: m['id']! as String,
      kind: PersonalCalendarEntryKind.fromStorage(m['kind']! as String),
      title: m['title']! as String,
      notes: m['notes'] as String?,
      date: date,
      isAllDay: (m['is_all_day'] as int? ?? 1) == 1,
      startMinutesFromMidnight: m['start_minutes'] as int?,
      endMinutesFromMidnight: m['end_minutes'] as int?,
      dutyGroupName: m['duty_group_name']! as String,
      createdAtMs: m['created_at']! as int,
      updatedAtMs: m['updated_at']! as int,
    );
  }
}
