import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/data/models/duty_type.dart';
import 'package:dienstplan/data/models/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/database_constants.dart';
import 'package:dienstplan/core/utils/schedule_key_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const int _currentVersion = kDatabaseCurrentVersion;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'dienstplan.db');
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
        date TEXT NOT NULL,
        date_ymd TEXT NOT NULL,
        service TEXT NOT NULL,
        duty_group_id TEXT NOT NULL,
        duty_group_name TEXT NOT NULL,
        duty_type_id TEXT NOT NULL,
        is_all_day INTEGER NOT NULL DEFAULT 0,
        config_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (date_ymd, config_name, duty_group_id, duty_type_id, service)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calendar_format TEXT NOT NULL,
        language TEXT,
        selected_duty_group TEXT,
        my_duty_group TEXT,
        active_config_name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create optimized indexes
    await _createOptimizedIndexes(db);

    AppLogger.i('Optimized database tables and indexes created successfully');
  }

  Future<void> _createOptimizedIndexes(DatabaseExecutor db) async {
    AppLogger.i('Creating optimized database indexes');

    // Composite indexes for common query patterns
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_date_config_service 
      ON schedules(date, config_name, service);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_config_date 
      ON schedules(config_name, date);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_duty_group 
      ON schedules(duty_group_id, date);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_all_day 
      ON schedules(is_all_day, date);
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_duty_types_config_id 
      ON duty_types(config_name, id);
    ''');

    // Note: Partial indexes with date() functions are not supported
    // SQLite considers date() non-deterministic
    // Regular indexes will be used instead

    // Additional helpful indexes for lookups involving date_ymd
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_ymd_config
      ON schedules(date_ymd, config_name);
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_schedules_config_ymd
      ON schedules(config_name, date_ymd);
    ''');

    AppLogger.i('Optimized indexes created successfully');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    AppLogger.i('Upgrading database from version $oldVersion to $newVersion');
    await db.transaction((txn) async {
      if (oldVersion < 5) {
        await _migrateToVersion5(txn);
      }
      if (oldVersion < 6) {
        await _migrateToVersion6(txn);
      }
      if (oldVersion < 7) {
        await _migrateToVersion7(txn);
      }
    });
  }

  Future<void> _migrateToVersion5(DatabaseExecutor db) async {
    try {
      AppLogger.i(
          'Migrating to version 5: Removing focused_day and selected_day columns');

      // Create a new settings table without the date columns
      await db.execute('''
        CREATE TABLE settings_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          calendar_format TEXT NOT NULL,
          language TEXT,
          selected_duty_group TEXT,
          my_duty_group TEXT,
          active_config_name TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Copy data from old table to new table (excluding the date columns)
      await db.execute('''
        INSERT INTO settings_new (
          id, calendar_format, language, selected_duty_group, 
          my_duty_group, active_config_name, created_at, updated_at
        )
        SELECT 
          id, calendar_format, language, selected_duty_group,
          my_duty_group, active_config_name, created_at, updated_at
        FROM settings
      ''');

      // Drop the old table
      await db.execute('DROP TABLE settings');

      // Rename the new table to the original name
      await db.execute('ALTER TABLE settings_new RENAME TO settings');

      AppLogger.i(
          'Successfully migrated to version 5: Removed date columns from settings');
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 5', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _migrateToVersion6(DatabaseExecutor db) async {
    try {
      AppLogger.i(
          'Migrating to version 6: Rebuilding schedules table with collision-safe IDs');

      // Create a new schedules table
      await db.execute('''
        CREATE TABLE schedules_new (
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

      // Copy data with new ID format and deduplicate by (date_ymd, config_name, duty_group_id)
      // Keep the most recently updated row per key
      await db.execute('''
        INSERT OR REPLACE INTO schedules_new (
          id, date, service, duty_group_id, duty_group_name, duty_type_id,
          is_all_day, config_name, created_at, updated_at
        )
        SELECT 
          substr(date, 1, 10) || '_' || config_name || '_' || duty_group_id || '_' || duty_type_id || '_' || service AS id,
          date, service, duty_group_id, duty_group_name, duty_type_id,
          is_all_day, config_name, created_at, updated_at
        FROM (
          SELECT * FROM schedules
          ORDER BY updated_at DESC
        )
        GROUP BY substr(date, 1, 10), config_name, duty_group_id, duty_type_id, service
      ''');

      // Drop old table and rename new one
      await db.execute('DROP TABLE schedules');
      await db.execute('ALTER TABLE schedules_new RENAME TO schedules');

      // Recreate optimized indexes
      await _createOptimizedIndexes(db);

      AppLogger.i(
          'Successfully migrated to version 6: schedules IDs updated and duplicates removed');
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 6', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _migrateToVersion7(DatabaseExecutor db) async {
    try {
      AppLogger.i(
          'Migrating to version 7: Rebuilding schedules table with composite PK and date_ymd');

      await db.execute('''
        CREATE TABLE schedules_new_v7 (
          date TEXT NOT NULL,
          date_ymd TEXT NOT NULL,
          service TEXT NOT NULL,
          duty_group_id TEXT NOT NULL,
          duty_group_name TEXT NOT NULL,
          duty_type_id TEXT NOT NULL,
          is_all_day INTEGER NOT NULL DEFAULT 0,
          config_name TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          PRIMARY KEY (date_ymd, config_name, duty_group_id, duty_type_id, service)
        )
      ''');

      await db.execute('''
        INSERT OR REPLACE INTO schedules_new_v7 (
          date, date_ymd, service, duty_group_id, duty_group_name, duty_type_id,
          is_all_day, config_name, created_at, updated_at
        )
        SELECT 
          date,
          substr(date, 1, 10) AS date_ymd,
          service, duty_group_id, duty_group_name, duty_type_id,
          is_all_day, config_name, created_at, updated_at
        FROM (
          SELECT * FROM schedules
          ORDER BY updated_at DESC
        )
        GROUP BY substr(date, 1, 10), config_name, duty_group_id, duty_type_id, service
      ''');

      await db.execute('DROP TABLE schedules');
      await db.execute('ALTER TABLE schedules_new_v7 RENAME TO schedules');

      await _createOptimizedIndexes(db);

      AppLogger.i(
          'Successfully migrated to version 7: schedules now use composite PK and date_ymd');
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 7', e, stackTrace);
      rethrow;
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
      const batchSize = 1000; // Increased batch size for better performance
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction((txn) async {
        for (var i = 0; i < schedules.length; i += batchSize) {
          final end = (i + batchSize < schedules.length)
              ? i + batchSize
              : schedules.length;
          final batch = txn.batch();
          final currentBatch = schedules.sublist(i, end);

          for (final schedule in currentBatch) {
            final String ymd = ScheduleKeyHelper.formatDateYmd(schedule.date);
            batch.insert(
              'schedules',
              {
                'date': schedule.date.toIso8601String(),
                'date_ymd': ymd,
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

          // Log progress for large saves
          if (schedules.length > 1000) {
            final progress = ((end) / schedules.length * 100).round();
            AppLogger.i(
                'Schedule saving progress: $progress% ($end/${schedules.length})');
          }
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

      // Use regular query - SQLite will automatically choose the best index
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date ASC, service ASC',
      );

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

  // Interface compatibility methods
  Future<void> initialize() async {
    return init();
  }

  // Schedule operations
  Future<List<Schedule>> getSchedules() async {
    return loadSchedulesOptimized();
  }

  Future<List<Schedule>> getSchedulesForDateRange(
      DateTime startDate, DateTime endDate) async {
    return loadSchedulesForDateRangeOptimized(startDate, endDate);
  }

  Future<void> saveSchedule(Schedule schedule) async {
    await saveSchedulesOptimized([schedule]);
  }

  Future<void> deleteSchedule(String id) async {
    try {
      AppLogger.i('Deleting schedule with id: $id');
      final db = await database;
      final parts = ScheduleKeyHelper.parseScheduleId(id);
      await db.delete(
        'schedules',
        where:
            'date_ymd = ? AND config_name = ? AND duty_group_id = ? AND duty_type_id = ? AND service = ?',
        whereArgs: [
          parts.dateYmd,
          parts.configName,
          parts.dutyGroupId,
          parts.dutyTypeId,
          parts.service,
        ],
      );
      AppLogger.i('Schedule deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error deleting schedule', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearSchedules() async {
    try {
      AppLogger.i('Clearing all schedules');
      final db = await database;
      await db.delete('schedules');
      AppLogger.i('All schedules cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }

  // Settings operations
  Future<Settings?> getSettings() async {
    return loadSettings();
  }

  Future<void> clearSettings() async {
    try {
      AppLogger.i('Clearing all settings');
      final db = await database;
      await db.delete('settings');
      AppLogger.i('All settings cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing settings', e, stackTrace);
      rethrow;
    }
  }

  // Utility operations
  Future<bool> hasData() async {
    try {
      AppLogger.i('Checking if database has data');
      final db = await database;
      final schedulesCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM schedules'));
      final settingsCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM settings'));
      final hasData = (schedulesCount ?? 0) > 0 || (settingsCount ?? 0) > 0;
      AppLogger.i('Database has data: $hasData');
      return hasData;
    } catch (e, stackTrace) {
      AppLogger.e('Error checking if database has data', e, stackTrace);
      return false;
    }
  }

  Future<void> clearAllData() async {
    try {
      AppLogger.i('Clearing all data');
      final db = await database;
      await db.delete('schedules');
      await db.delete('duty_types');
      await db.delete('settings');
      AppLogger.i('All data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error clearing all data', e, stackTrace);
      rethrow;
    }
  }

  // Additional methods from old DatabaseService
  Future<void> saveDutyTypes(
      String configName, Map<String, DutyType> dutyTypes) async {
    return saveDutyTypesOptimized(configName, dutyTypes);
  }

  Future<DutyType?> loadDutyType(String serviceId, String configName) async {
    try {
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
    } catch (e, stackTrace) {
      AppLogger.e('Error loading duty type', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    return saveSchedulesOptimized(schedules);
  }

  Future<List<Schedule>> loadSchedules() async {
    return loadSchedulesOptimized();
  }

  Future<void> saveSettings(Settings settings) async {
    try {
      AppLogger.i('Saving settings: $settings');
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final settingsMap = settings.toMap();
      settingsMap['created_at'] = now;
      settingsMap['updated_at'] = now;

      await db.delete('settings');
      await db.insert('settings', settingsMap);
      AppLogger.i('Settings saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  Future<Settings?> loadSettings() async {
    try {
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
    } catch (e, stackTrace) {
      AppLogger.e('Error loading settings', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    try {
      AppLogger.i('Clearing database');
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
    return loadSchedulesForDateRangeOptimized(startDate, endDate,
        configName: configName);
  }
}
