import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule.dart';
import '../models/duty_schedule_config.dart';
import 'package:intl/intl.dart';
import '../utils/logger.dart';

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
            start_time TEXT,
            end_time TEXT,
            all_day INTEGER,
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
            language TEXT
          )
        ''');
        AppLogger.i('Database tables created successfully');
      },
    );
    return _database!;
  }

  Future<void> init() async {
    try {
      AppLogger.i('Opening database connection');
      await database;
      AppLogger.i('Database tables created successfully');
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
            'service_id': entry.key,
            'label': entry.value.label,
            'all_day': entry.value.allDay ? 1 : 0,
            'start_time': entry.value.startTime,
            'end_time': entry.value.endTime,
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
      final batch = db.batch();

      for (final schedule in schedules) {
        batch.insert(
          'schedules',
          {
            'id': '${schedule.date.toIso8601String()}_${schedule.dutyGroupId}',
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
      }

      await batch.commit();
      AppLogger.i('Schedules saved successfully');
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

  Future<void> saveSettings({
    required String calendarFormat,
    required DateTime focusedDay,
    required DateTime selectedDay,
    String? language,
  }) async {
    AppLogger.i(
        'Saving settings: format=$calendarFormat, focused=$focusedDay, selected=$selectedDay, language=$language');
    final db = await database;
    await db.delete('settings');
    await db.insert('settings', {
      'calendar_format': calendarFormat,
      'focused_day': focusedDay.toIso8601String(),
      'selected_day': selectedDay.toIso8601String(),
      if (language != null) 'language': language,
    });
    AppLogger.i('Settings saved successfully');
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    AppLogger.i('Loading settings');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isEmpty) {
      AppLogger.i('No settings found');
      return null;
    }

    final map = maps.first;
    final settings = {
      'calendar_format': map['calendar_format'] as String,
      'focused_day': DateTime.parse(map['focused_day'] as String),
      'selected_day': DateTime.parse(map['selected_day'] as String),
      if (map['language'] != null) 'language': map['language'] as String,
    };
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
        dutyTypes[map['service_id'] as String] = DutyType.fromMap(map);
      }

      AppLogger.i('Loaded ${dutyTypes.length} duty types');
      return dutyTypes;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading duty types', e, stackTrace);
      rethrow;
    }
  }
}
