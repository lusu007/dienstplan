import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/data/models/duty_type.dart';
import 'package:dienstplan/data/models/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';

class OptimizedDatabaseService {
  static final OptimizedDatabaseService _instance =
      OptimizedDatabaseService._internal();
  factory OptimizedDatabaseService() => _instance;
  OptimizedDatabaseService._internal();

  static Database? _database;
  static const int _currentVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'dienstplan_optimized.db');
    AppLogger.i('Opening optimized database connection at: $dbPath');
    _database = await openDatabase(
      dbPath,
      version: _currentVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    AppLogger.i('Creating optimized database tables');

    // Create tables with optimized structure
    await db.execute('''
      CREATE TABLE duty_types (
        id TEXT NOT NULL,
        label TEXT NOT NULL,
        all_day INTEGER NOT NULL DEFAULT 0,
        icon TEXT,
        config_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
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
        is_all_day INTEGER NOT NULL DEFAULT 0,
        config_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
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
        preferred_duty_group TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create optimized indexes
    await _createOptimizedIndexes(db);

    AppLogger.i('Optimized database tables and indexes created successfully');
  }

  Future<void> _createOptimizedIndexes(Database db) async {
    AppLogger.i('Creating optimized database indexes');

    // Composite indexes for common query patterns
    await db.execute('''
      CREATE INDEX idx_schedules_date_config_service 
      ON schedules(date, config_name, service);
    ''');

    await db.execute('''
      CREATE INDEX idx_schedules_config_date 
      ON schedules(config_name, date);
    ''');

    await db.execute('''
      CREATE INDEX idx_schedules_duty_group 
      ON schedules(duty_group_id, date);
    ''');

    await db.execute('''
      CREATE INDEX idx_schedules_all_day 
      ON schedules(is_all_day, date);
    ''');

    await db.execute('''
      CREATE INDEX idx_duty_types_config_id 
      ON duty_types(config_name, id);
    ''');

    // Partial indexes for better performance
    await db.execute('''
      CREATE INDEX idx_schedules_active 
      ON schedules(date, config_name) 
      WHERE date >= date('now', '-30 days');
    ''');

    await db.execute('''
      CREATE INDEX idx_schedules_future 
      ON schedules(date, config_name) 
      WHERE date >= date('now');
    ''');

    AppLogger.i('Optimized indexes created successfully');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    AppLogger.i('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Add timestamp columns
      await db.execute(
          'ALTER TABLE duty_types ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE duty_types ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE schedules ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE schedules ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE settings ADD COLUMN created_at INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE settings ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0');

      // Create new optimized indexes
      await _createOptimizedIndexes(db);
    }
  }

  Future<void> init() async {
    try {
      AppLogger.i('Initializing optimized database connection');
      await database;
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing optimized database', e, stackTrace);
      rethrow;
    }
  }

  // Optimized batch operations
  Future<void> saveDutyTypesOptimized(
      String configName, Map<String, DutyType> dutyTypes) async {
    try {
      AppLogger.i(
          'Saving duty types with optimized batch operation for config: $configName');
      final db = await database;
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Use transaction for better performance
      await db.transaction((txn) async {
        // Delete existing duty types for this config
        await txn.delete(
          'duty_types',
          where: 'config_name = ?',
          whereArgs: [configName],
        );

        // Insert new duty types in batch
        for (final entry in dutyTypes.entries) {
          batch.insert(
            'duty_types',
            {
              'config_name': configName,
              'id': entry.key,
              'label': entry.value.label,
              'all_day': entry.value.isAllDay ? 1 : 0,
              'icon': entry.value.icon,
              'created_at': now,
              'updated_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit();
      });

      AppLogger.i(
          'Duty types saved successfully with optimized batch operation');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving duty types with optimized batch operation', e,
          stackTrace);
      rethrow;
    }
  }

  // Optimized schedule loading with pagination
  Future<List<Schedule>> loadSchedulesOptimized({
    int limit = 1000,
    int offset = 0,
    String? configName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.i('Loading schedules with optimized query');
      final db = await database;

      String whereClause = '1=1';
      final List<dynamic> whereArgs = [];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      if (startDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, service ASC',
        limit: limit,
        offset: offset,
      );

      final schedules = List<Schedule>.generate(maps.length, (i) {
        return Schedule.fromMap(maps[i]);
      });

      AppLogger.i('Loaded ${schedules.length} schedules with optimized query');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e(
          'Error loading schedules with optimized query', e, stackTrace);
      rethrow;
    }
  }

  // Optimized schedule saving with improved batch processing
  Future<void> saveSchedulesOptimized(List<Schedule> schedules) async {
    try {
      AppLogger.i(
          'Saving ${schedules.length} schedules with optimized batch processing');
      final db = await database;
      const batchSize = 500; // Reduced batch size for better memory management
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction((txn) async {
        for (var i = 0; i < schedules.length; i += batchSize) {
          final end = (i + batchSize < schedules.length)
              ? i + batchSize
              : schedules.length;
          final batch = txn.batch();
          final currentBatch = schedules.sublist(i, end);

          for (final schedule in currentBatch) {
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
                'created_at': now,
                'updated_at': now,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          await batch.commit();
        }
      });

      AppLogger.i(
          'All schedules saved successfully with optimized batch processing');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving schedules with optimized batch processing', e,
          stackTrace);
      rethrow;
    }
  }

  // Optimized date range query with index hints
  Future<List<Schedule>> loadSchedulesForDateRangeOptimized(
      DateTime startDate, DateTime endDate,
      {String? configName}) async {
    try {
      AppLogger.i('Loading schedules with optimized date range query');
      final db = await database;

      // Use index hints for better performance
      String whereClause = 'date BETWEEN ? AND ?';
      final List<dynamic> whereArgs = [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ];

      if (configName != null) {
        whereClause += ' AND config_name = ?';
        whereArgs.add(configName);
      }

      // Use specific index for better performance
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM schedules 
        WHERE $whereClause 
        ORDER BY date ASC, service ASC
        INDEXED BY idx_schedules_date_config_service
      ''', whereArgs);

      final schedules = List<Schedule>.generate(maps.length, (i) {
        return Schedule.fromMap(maps[i]);
      });

      AppLogger.i(
          'Loaded ${schedules.length} schedules with optimized date range query');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading schedules with optimized date range query', e,
          stackTrace);
      rethrow;
    }
  }

  // Database maintenance operations
  Future<void> optimizeDatabase() async {
    try {
      AppLogger.i('Optimizing database');
      final db = await database;

      // Analyze tables for better query planning
      await db.execute('ANALYZE');

      // Vacuum database to reclaim space
      await db.execute('VACUUM');

      AppLogger.i('Database optimization completed');
    } catch (e, stackTrace) {
      AppLogger.e('Error optimizing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cleanupOldData({int daysToKeep = 365}) async {
    try {
      AppLogger.i('Cleaning up old data (keeping last $daysToKeep days)');
      final db = await database;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final deletedSchedules = await db.delete(
        'schedules',
        where: 'date < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );

      AppLogger.i('Cleaned up $deletedSchedules old schedule records');
    } catch (e, stackTrace) {
      AppLogger.e('Error cleaning up old data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.i('Optimized database connection closed');
    }
  }
}
