-- Schema created by App Store release v0.15.2 (database version 14).
CREATE TABLE duty_types (
        id TEXT NOT NULL,
        label TEXT NOT NULL,
        all_day INTEGER NOT NULL DEFAULT 0,
        icon TEXT,
        config_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id, config_name)
      );
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
      );
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
        holiday_accent_color INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
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
      );
PRAGMA user_version = 14;
