import 'package:sqflite/sqflite.dart';

import 'dart:convert';
import 'dart:io';

import 'package:dienstplan/data/services/database_service.dart';
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

  Future<void> seedLegacy({List<String> missing = const []}) async {
    final schema = await File('test/fixtures/database_v14.sql').readAsString();
    for (final statement in schema.split(';')) {
      if (statement.trim().isNotEmpty) await sql(statement);
    }
    await sql(
      "INSERT INTO settings (id, calendar_format, language, my_duty_group, active_config_name, partner_accent_color, my_accent_color, holiday_accent_color, created_at, updated_at) VALUES (1, 'month', 'de', 'B', 'legacy-plan', 123, 456, 789, 100, 200)",
    );
    await sql(
      "INSERT INTO schedules (date, date_ymd, service, duty_group_id, duty_group_name, duty_type_id, is_all_day, config_name, created_at, updated_at) VALUES ('2026-10-12', '2026-10-12', 'Frühdienst', 'B', 'B', 'F', 0, 'legacy-plan', 100, 200)",
    );
    for (final column in missing) {
      await sql('ALTER TABLE settings DROP COLUMN $column');
    }
  }

  for (final missing in <List<String>>[
    [],
    ['my_accent_color'],
    [
      'my_accent_color',
      'theme_mode',
      'partner_config_name',
      'partner_duty_group',
      'show_school_holidays',
      'school_holiday_state_code',
      'last_school_holiday_refresh',
      'holiday_accent_color',
    ],
  ]) {
    test('v0.15.2 upgrade preserves data with missing $missing', () async {
      await seedLegacy(missing: missing);
      final db = await service.database;
      final settings = (await db.query('settings')).single;
      expect(settings['id'], 1);
      expect(settings['language'], 'de');
      expect(settings['my_duty_group'], 'B');
      expect(settings['active_config_name'], 'legacy-plan');
      expect(settings['partner_accent_color'], 123);
      expect(settings['created_at'], 100);
      expect(settings['updated_at'], 200);
      expect(
        settings['my_accent_color'],
        missing.contains('my_accent_color') ? null : 456,
      );
      expect(
        settings['holiday_accent_color'],
        missing.contains('holiday_accent_color') ? null : 789,
      );
      expect(settings.containsKey('calendar_format'), isFalse);
      expect((await db.query('schedules')).single['service'], 'Frühdienst');
      expect(await db.getVersion(), 20);
      await service.close();
      expect(
        (await (await service.database).query('settings')).single,
        settings,
      );
    });
  }

  test(
    'rebuilding settings preserves an existing compact-list preference',
    () async {
      await seedLegacy();
      await sql(
        'ALTER TABLE settings ADD COLUMN show_other_duty_groups_in_compact_list INTEGER',
      );
      await sql(
        'UPDATE settings SET show_other_duty_groups_in_compact_list = 1',
      );
      final db = await service.database;
      expect(
        (await db.query('settings'))
            .single['show_other_duty_groups_in_compact_list'],
        1,
      );
    },
  );
  test(
    'missing required timestamps fail without replacing legacy settings',
    () async {
      await seedLegacy(missing: ['created_at']);
      await expectLater(
        service.database,
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('no such column: created_at'),
          ),
        ),
      );
      expect(
        (await sql('SELECT id, active_config_name FROM settings'))['rows'],
        [
          [1, 'legacy-plan'],
        ],
      );
      expect((await sql('PRAGMA user_version'))['rows'], [
        [14],
      ]);
    },
  );

  test('empty legacy settings with missing optional columns upgrade', () async {
    await seedLegacy(missing: ['my_accent_color']);
    await sql('DELETE FROM settings');
    final db = await service.database;
    expect(await db.query('settings'), isEmpty);
    expect(await db.getVersion(), 20);
    expect((await db.query('schedules')).single['service'], 'Frühdienst');
  });
}
