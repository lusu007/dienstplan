import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/database_constants.dart';

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
      onOpen: _configureDatabase,
    );
    return _database!;
  }

  Future<void> _configureDatabase(Database db) async {
    AppLogger.i('Configuring database with performance optimizations');

    try {
      // Enable WAL mode for better write performance and concurrent reads
      await db.rawQuery('PRAGMA journal_mode=WAL');

      // Set synchronous to NORMAL for better performance while maintaining data safety
      await db.rawQuery('PRAGMA synchronous=NORMAL');

      // Enable foreign key constraints for data integrity
      await db.rawQuery('PRAGMA foreign_keys=ON');

      // Additional performance optimizations
      await db.rawQuery(
        'PRAGMA cache_size=10000',
      ); // Increase cache size (10MB)
      await db.rawQuery(
        'PRAGMA temp_store=MEMORY',
      ); // Store temporary tables in memory

      AppLogger.i('Database performance optimizations applied');
    } catch (e, stackTrace) {
      AppLogger.e('Error applying database optimizations', e, stackTrace);
      // Continue without optimizations rather than failing completely
    }
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
        theme_mode TEXT,
        partner_config_name TEXT,
        partner_duty_group TEXT,
        partner_accent_color INTEGER,
        my_accent_color INTEGER,
        show_school_holidays INTEGER,
        school_holiday_state_code TEXT,
        last_school_holiday_refresh TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedule_configs (
        name TEXT PRIMARY KEY,
        version TEXT NOT NULL,
        display_name TEXT NOT NULL,
        description TEXT,
        police_authority TEXT,
        icon TEXT,
        start_date TEXT NOT NULL,
        start_week_day TEXT NOT NULL,
        days TEXT NOT NULL,
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

    // Create school_holidays table for offline functionality
    await db.execute('''
      CREATE TABLE school_holidays (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        state_code TEXT NOT NULL,
        state_name TEXT NOT NULL,
        year INTEGER NOT NULL,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        description TEXT,
        type TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(state_code, year, name, start_date)
      )
    ''');

    // Create indexes for school_holidays table
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_school_holidays_state_year 
      ON school_holidays(state_code, year)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_school_holidays_dates 
      ON school_holidays(start_date, end_date)
    ''');

    // Note: Partial indexes with date() functions are not supported
    // SQLite considers date() non-deterministic
    // Regular indexes will be used instead

    // Check if date_ymd column exists before creating indexes on it
    try {
      await db.execute('SELECT date_ymd FROM schedules LIMIT 1');

      // Additional helpful indexes for lookups involving date_ymd
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_schedules_ymd_config
        ON schedules(date_ymd, config_name);
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_schedules_config_ymd
        ON schedules(config_name, date_ymd);
      ''');
    } catch (e) {
      AppLogger.i('date_ymd column not available, skipping date_ymd indexes');
    }

    AppLogger.i('Optimized indexes created successfully');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
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
      if (oldVersion < 8) {
        await _migrateToVersion8(txn);
      }
      if (oldVersion < 9) {
        await _migrateToVersion9(txn);
      }
      if (oldVersion < 10) {
        await _migrateToVersion10(txn);
      }
      if (oldVersion < 11) {
        await _migrateToVersion11(txn);
      }
      if (oldVersion < 12) {
        await _migrateToVersion12(txn);
      }

      // Create any missing indexes after all migrations are complete
      await _createOptimizedIndexes(txn);
    });
  }

  Future<void> _migrateToVersion5(DatabaseExecutor db) async {
    try {
      AppLogger.i(
        'Migrating to version 5: Removing focused_day and selected_day columns',
      );

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
        'Successfully migrated to version 5: Removed date columns from settings',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 5', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _migrateToVersion6(DatabaseExecutor db) async {
    try {
      AppLogger.i(
        'Migrating to version 6: Rebuilding schedules table with collision-safe IDs',
      );

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

      AppLogger.i(
        'Successfully migrated to version 6: schedules IDs updated and duplicates removed',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 6', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _migrateToVersion7(DatabaseExecutor db) async {
    try {
      AppLogger.i(
        'Migrating to version 7: Rebuilding schedules table with composite PK and date_ymd',
      );

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

      AppLogger.i(
        'Successfully migrated to version 7: schedules now use composite PK and date_ymd',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 7', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _migrateToVersion8(DatabaseExecutor db) async {
    try {
      AppLogger.i('Migrating to version 8: Add theme_mode to settings');
      await db.execute('''
        ALTER TABLE settings ADD COLUMN theme_mode TEXT
      ''');
      AppLogger.i('Successfully migrated to version 8: theme_mode added');
    } catch (e, stackTrace) {
      // Column might already exist if user reinstalled or partial migration
      AppLogger.e('Error during migration to version 8', e, stackTrace);
    }
  }

  Future<void> _migrateToVersion9(DatabaseExecutor db) async {
    try {
      AppLogger.i('Migrating to version 9: Add partner fields to settings');
      await db.execute('''
        ALTER TABLE settings ADD COLUMN partner_config_name TEXT
      ''');
      await db.execute('''
        ALTER TABLE settings ADD COLUMN partner_duty_group TEXT
      ''');
      await db.execute('''
        ALTER TABLE settings ADD COLUMN partner_accent_color INTEGER
      ''');
      AppLogger.i('Successfully migrated to version 9: partner fields added');
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 9', e, stackTrace);
    }
  }

  Future<void> _migrateToVersion10(DatabaseExecutor db) async {
    try {
      AppLogger.i('Migrating to version 10: Add my accent color to settings');

      // First check if the column already exists
      final columns = await db.rawQuery('PRAGMA table_info(settings)');
      final hasMyAccentColor = columns.any(
        (col) => col['name'] == 'my_accent_color',
      );

      if (!hasMyAccentColor) {
        await db.execute('''
          ALTER TABLE settings ADD COLUMN my_accent_color INTEGER
        ''');
        AppLogger.i(
          'Successfully migrated to version 10: my accent color added',
        );
      } else {
        AppLogger.i(
          'Column my_accent_color already exists, skipping migration',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 10', e, stackTrace);
      // Don't rethrow - let the migration continue
      AppLogger.i('Migration to version 10 failed, but continuing...');
    }
  }

  Future<void> _migrateToVersion11(DatabaseExecutor db) async {
    try {
      AppLogger.i('Migrating to version 11: Add schedule_configs table');

      // Check if the table already exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='schedule_configs'",
      );

      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE schedule_configs (
            name TEXT PRIMARY KEY,
            version TEXT NOT NULL,
            display_name TEXT NOT NULL,
            description TEXT,
            police_authority TEXT,
            icon TEXT,
            start_date TEXT NOT NULL,
            start_week_day TEXT NOT NULL,
            days TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        AppLogger.i(
          'Successfully migrated to version 11: schedule_configs table added',
        );
      } else {
        AppLogger.i(
          'Table schedule_configs already exists, skipping migration',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 11', e, stackTrace);
      // Don't rethrow - let the migration continue
      AppLogger.i('Migration to version 11 failed, but continuing...');
    }
  }

  Future<void> _migrateToVersion12(DatabaseExecutor db) async {
    try {
      AppLogger.i(
        'Migrating to version 12: Add school holiday fields to settings',
      );
      // Add columns if they do not exist
      final columns = await db.rawQuery('PRAGMA table_info(settings)');
      final hasShowSchoolHolidays = columns.any(
        (col) => col['name'] == 'show_school_holidays',
      );
      final hasSchoolHolidayStateCode = columns.any(
        (col) => col['name'] == 'school_holiday_state_code',
      );
      final hasLastRefreshTime = columns.any(
        (col) => col['name'] == 'last_school_holiday_refresh',
      );

      if (!hasShowSchoolHolidays) {
        await db.execute(
          'ALTER TABLE settings ADD COLUMN show_school_holidays INTEGER',
        );
      }
      if (!hasSchoolHolidayStateCode) {
        await db.execute(
          'ALTER TABLE settings ADD COLUMN school_holiday_state_code TEXT',
        );
      }
      if (!hasLastRefreshTime) {
        await db.execute(
          'ALTER TABLE settings ADD COLUMN last_school_holiday_refresh TEXT',
        );
      }

      // Create school_holidays table for offline functionality
      await db.execute('''
        CREATE TABLE IF NOT EXISTS school_holidays (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          state_code TEXT NOT NULL,
          state_name TEXT NOT NULL,
          year INTEGER NOT NULL,
          name TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          description TEXT,
          type TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(state_code, year, name, start_date)
        )
      ''');

      // Create indexes for better query performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_school_holidays_state_year 
        ON school_holidays(state_code, year)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_school_holidays_dates 
        ON school_holidays(start_date, end_date)
      ''');

      // Check if school_holidays table exists and add missing columns if needed
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='school_holidays'",
      );

      if (tables.isNotEmpty) {
        // Table exists, check which columns are missing
        final columns = await db.rawQuery('PRAGMA table_info(school_holidays)');
        final columnNames = columns.map((col) => col['name'] as String).toSet();

        if (!columnNames.contains('state_name')) {
          await db.execute(
            'ALTER TABLE school_holidays ADD COLUMN state_name TEXT',
          );
          AppLogger.i('Added state_name column to school_holidays table');
        }

        if (!columnNames.contains('description')) {
          await db.execute(
            'ALTER TABLE school_holidays ADD COLUMN description TEXT',
          );
          AppLogger.i('Added description column to school_holidays table');
        }

        if (!columnNames.contains('type')) {
          await db.execute('ALTER TABLE school_holidays ADD COLUMN type TEXT');
          AppLogger.i('Added type column to school_holidays table');
        }
      }

      AppLogger.i(
        'Successfully migrated to version 12: school holiday fields and table added',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error during migration to version 12', e, stackTrace);
    }
  }

  Future<void> init() async {
    // Defer opening the database until first real use to avoid startup jank
    AppLogger.d('Deferring database initialization until first access');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.i('Optimized database connection closed');
    }
  }

  // Interface compatibility methods retained for backward compatibility
  Future<void> initialize() async => init();
}
