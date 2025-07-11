import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/models/duty_type.dart';
import 'package:dienstplan/models/settings.dart';
import 'package:dienstplan/utils/logger.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'dienstplan.db');
    AppLogger.i('Opening database connection at: $dbPath');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        AppLogger.i('Creating database tables');
        await db.execute('''
          CREATE TABLE duty_types (
            id TEXT,
            label TEXT,
            all_day INTEGER,
            icon TEXT,
            config_name TEXT,
            PRIMARY KEY (id, config_name)
          )
        ''');

        await db.execute('''
          CREATE TABLE schedules (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            service TEXT NOT NULL,
            duty_group_id TEXT NOT NULL,
            duty_group_name TEXT NOT NULL,
            duty_type_id TEXT NOT NULL,
            is_all_day INTEGER NOT NULL,
            config_name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            calendar_format TEXT NOT NULL,
            focused_day TEXT NOT NULL,
            selected_day TEXT NOT NULL,
            language TEXT,
            selected_duty_group TEXT,
            preferred_duty_group TEXT
          )
        ''');

        AppLogger.i('Creating database indexes');
        await db.execute('''
          CREATE INDEX idx_schedules_date 
          ON schedules(date);
        ''');

        await db.execute('''
          CREATE INDEX idx_schedules_config 
          ON schedules(config_name);
        ''');

        await db.execute('''
          CREATE INDEX idx_schedules_date_config 
          ON schedules(date, config_name);
        ''');

        await db.execute('''
          CREATE INDEX idx_duty_types_config 
          ON duty_types(config_name);
        ''');

        AppLogger.i('Database tables and indexes created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        AppLogger.i(
            'Upgrading database from version $oldVersion to $newVersion');
        // No migrations needed during development
      },
    );
    return _database!;
  }

  Future<void> init() async {
    try {
      AppLogger.i('Opening database connection');
      await database;
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveDutyTypes(
      String configName, Map<String, DutyType> dutyTypes) async {
    try {
      AppLogger.i('Saving duty types for config: $configName');
      final db = await database;
      final batch = db.batch();

      for (final entry in dutyTypes.entries) {
        batch.insert(
          'duty_types',
          {
            'config_name': configName,
            'id': entry.key,
            'label': entry.value.label,
            'all_day': entry.value.isAllDay ? 1 : 0,
            'icon': entry.value.icon,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      AppLogger.i('Duty types saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving duty types', e, stackTrace);
      rethrow;
    }
  }

  Future<DutyType?> loadDutyType(String serviceId, String configName) async {
    AppLogger.d('Loading duty type: $serviceId for config: $configName');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'duty_types',
      where: 'id = ? AND config_name = ?',
      whereArgs: [serviceId, configName],
    );

    if (maps.isEmpty) {
      AppLogger.d('No duty type found for: $serviceId');
      return null;
    }

    return DutyType.fromMap(maps.first);
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    try {
      AppLogger.i('Saving ${schedules.length} schedules to database');
      final db = await database;
      const batchSize = 1000; // Process 1000 schedules at a time

      for (var i = 0; i < schedules.length; i += batchSize) {
        final end = (i + batchSize < schedules.length)
            ? i + batchSize
            : schedules.length;
        final batch = db.batch();
        final currentBatch = schedules.sublist(i, end);

        for (final schedule in currentBatch) {
          try {
            batch.insert(
              'schedules',
              {
                'id':
                    '${schedule.date.toIso8601String()}_${schedule.dutyGroupId}',
                'date': schedule.date.toIso8601String(),
                'service': schedule.service,
                'duty_group_id': schedule.dutyGroupId,
                'duty_group_name': schedule.dutyGroupName,
                'duty_type_id': schedule.dutyTypeId,
                'is_all_day': schedule.isAllDay ? 1 : 0,
                'config_name': schedule.configName,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            AppLogger.e('Error inserting schedule: ${schedule.toString()}', e);
            rethrow;
          }
        }

        try {
          await batch.commit();
        } catch (e) {
          AppLogger.e('Error committing batch ${i ~/ batchSize + 1}', e);
          rethrow;
        }
      }

      AppLogger.i('All schedules saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Schedule>> loadSchedules() async {
    try {
      AppLogger.i('Loading schedules from database');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('schedules');
      final schedules = List<Schedule>.generate(maps.length, (i) {
        return Schedule.fromMap(maps[i]);
      });
      AppLogger.i('Loaded ${schedules.length} schedules from database');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveSettings(Settings settings) async {
    AppLogger.i('Saving settings: $settings');
    final db = await database;
    await db.delete('settings');
    await db.insert('settings', settings.toMap());
    AppLogger.i('Settings saved successfully');
  }

  Future<Settings?> loadSettings() async {
    AppLogger.i('Loading settings');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isEmpty) {
      AppLogger.i('No settings found');
      return null;
    }

    final settings = Settings.fromMap(maps.first);
    AppLogger.i('Settings loaded: $settings');
    return settings;
  }

  Future<void> clearDatabase() async {
    try {
      AppLogger.i('Clearing entire database');
      final db = await database;
      await db.delete('schedules');
      await db.delete('duty_types');
      await db.delete('settings');
      AppLogger.i('Database cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearDutySchedule(String configName) async {
    try {
      AppLogger.i('Clearing duty schedule for config: $configName');
      final db = await database;
      await db.delete(
        'schedules',
        where: 'config_name = ?',
        whereArgs: [configName],
      );
      await db.delete(
        'duty_types',
        where: 'config_name = ?',
        whereArgs: [configName],
      );
      AppLogger.i('Duty schedule cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing duty schedule', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, DutyType>> loadDutyTypes(String configName) async {
    try {
      AppLogger.i('Loading duty types for config: $configName');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'duty_types',
        where: 'config_name = ?',
        whereArgs: [configName],
      );

      final dutyTypes = <String, DutyType>{};
      for (final map in maps) {
        dutyTypes[map['id'] as String] = DutyType.fromMap(map);
      }

      AppLogger.i('Loaded ${dutyTypes.length} duty types');
      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading duty types', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Schedule>> loadSchedulesForDateRange(
      DateTime startDate, DateTime endDate,
      {String? configName}) async {
    try {
      AppLogger.i(
          'Loading schedules from database for date range: $startDate to $endDate');
      final db = await database;

      // Normalize dates to UTC midnight
      final normalizedStartDate =
          DateTime.utc(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate =
          DateTime.utc(endDate.year, endDate.month, endDate.day);

      String whereClause = 'date BETWEEN ? AND ?';
      final List<dynamic> whereArgs = [
        normalizedStartDate.toIso8601String(),
        normalizedEndDate.toIso8601String(),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
      );

      final schedules = List<Schedule>.generate(maps.length, (i) {
        return Schedule.fromMap(maps[i]);
      });

      AppLogger.i(
          'Loaded ${schedules.length} schedules from database for date range');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules for date range', e, stackTrace);
      rethrow;
    }
  }
}
