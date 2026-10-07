import 'package:sqflite/sqflite.dart';

import 'dart:convert';
import 'dart:io';

import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/daos/personal_calendar_entries_dao.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Use real SQLite through Python's standard library in the host test runner,
// without adding a production or dev dependency for the platform plugin.
const _sqlite = '''
import sqlite3,json,sys
con=sqlite3.connect(sys.argv[1])
cur=con.execute(sys.argv[2],json.loads(sys.argv[3]))
result={"columns":[x[0] for x in cur.description],"rows":cur.fetchall()} if cur.description else {"id":cur.lastrowid,"count":cur.rowcount}
con.commit()
print(json.dumps(result))
con.close()
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactorySqflitePlugin;
  late Directory temp;
  late String path;
  final service = DatabaseService();
  Future<Map<String, dynamic>> sql(
    String statement, [
    List<Object?> args = const [],
  ]) async {
    final process = await Process.run('python3', [
      '-c',
      _sqlite,
      path,
      statement,
      jsonEncode(args),
    ]);
    if (process.exitCode != 0) {
      throw StateError('${process.stderr} ($statement)');
    }
    return jsonDecode(process.stdout as String) as Map<String, dynamic>;
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('personal-duty-db-');
    path = '${temp.path}/dienstplan.db';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.tekartik.sqflite'), (
          call,
        ) async {
          final args = call.arguments is Map
              ? call.arguments as Map
              : <dynamic, dynamic>{};
          switch (call.method) {
            case 'getDatabasesPath':
              return temp.path;
            case 'openDatabase':
              return <String, Object?>{'id': 1};
            case 'closeDatabase':
              return null;
            case 'databaseExists':
              return File(path).existsSync();
            case 'execute':
            case 'query':
            case 'insert':
            case 'update':
              final statement = args['sql'] as String;
              // sqflite transaction boundaries span calls; each host SQLite call
              // commits separately. Migration data/schema assertions remain real.
              if (statement.startsWith('BEGIN')) return {'transactionId': 1};
              if (statement == 'COMMIT' || statement == 'ROLLBACK') return null;
              final result = await sql(
                statement,
                (args['arguments'] as List?)?.cast<Object?>() ?? [],
              );
              if (call.method == 'query') return result;
              if (call.method == 'insert') return result['id'];
              if (call.method == 'update') return result['count'];
              return null;
            default:
              throw StateError('Unexpected sqflite call ${call.method}');
          }
        });
  });
  tearDown(() async {
    await service.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.tekartik.sqflite'),
          null,
        );
    await temp.delete(recursive: true);
  });
  test(
    'upgrade tolerates v19 database with existing end date column',
    () async {
      final dao = PersonalCalendarEntriesDao(service);
      final night = PersonalCalendarEntry(
        id: 'existing-night',
        kind: PersonalCalendarEntryKind.personalDuty,
        title: 'Bestehender Nachtdienst',
        date: DateTime.utc(2026, 10, 7),
        endDate: DateTime.utc(2026, 10, 8),
        isAllDay: false,
        startMinutesFromMidnight: 1320,
        endMinutesFromMidnight: 360,
        dutyGroupName: 'Privat',
        createdAtMs: 1,
        updatedAtMs: 2,
      );
      await dao.upsert(night);
      await service.close();
      await sql('PRAGMA user_version = 19');
      final entries = await dao.loadBetween(
        startDate: night.date,
        endDate: night.date,
      );
      expect(entries.single, night);
      expect((await sql('PRAGMA user_version'))['rows'], [
        [20],
      ]);
    },
  );
  test('fresh database and v19 upgrade retain old entries and round-trip end dates', () async {
    final dao = PersonalCalendarEntriesDao(service);
    final old = PersonalCalendarEntry(
      id: 'legacy',
      kind: PersonalCalendarEntryKind.personalDuty,
      title: 'Alter Dienst',
      date: DateTime.utc(2026, 12, 31),
      isAllDay: false,
      startMinutesFromMidnight: 480,
      endMinutesFromMidnight: 960,
      dutyGroupName: 'Privat',
      createdAtMs: 1,
      updatedAtMs: 2,
    );
    await dao.upsert(old); // Exercise fresh schema creation.
    await service.close();
    await sql('ALTER TABLE personal_calendar_entries DROP COLUMN end_date_ymd');
    await sql('PRAGMA user_version = 19');
    final loaded = await dao.loadBetween(
      startDate: old.date,
      endDate: old.date,
    );
    expect(loaded.single, old);
    final night = old.copyWith(
      id: 'night',
      title: 'Nachtdienst',
      startMinutesFromMidnight: 1320,
      endMinutesFromMidnight: 360,
      endDate: DateTime.utc(2027, 1, 2),
    );
    await dao.upsert(night);
    await service.close();
    final reread = await dao.loadBetween(
      startDate: old.date,
      endDate: old.date,
    );
    expect(reread, containsAll([old, night]));
    expect((await sql('PRAGMA user_version'))['rows'], [
      [20],
    ]);
  });
}
