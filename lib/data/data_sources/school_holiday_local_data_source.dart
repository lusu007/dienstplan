import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/school_holiday.dart';
import '../daos/school_holidays_dao.dart';

/// Local data source for caching school holidays
abstract interface class SchoolHolidayLocalDataSource {
  /// Get cached holidays for a specific state and year
  Future<List<SchoolHoliday>?> getCachedHolidays({
    required String stateCode,
    required int year,
  });

  /// Cache holidays for a specific state and year
  Future<void> cacheHolidays({
    required String stateCode,
    required int year,
    required List<SchoolHoliday> holidays,
  });

  /// Clear all cached holidays
  Future<void> clearCache();

  /// Get the last update timestamp for cached holidays
  Future<DateTime?> getLastUpdateTime({
    required String stateCode,
    required int year,
  });
}

/// Implementation of SchoolHolidayLocalDataSource using SharedPreferences
class SchoolHolidayLocalDataSourceImpl implements SchoolHolidayLocalDataSource {
  final SharedPreferences _prefs;

  static const _holidayCachePrefix = 'school_holidays_';
  static const _lastUpdatePrefix = 'school_holidays_update_';
  static const _cacheKeysList = 'school_holidays_cache_keys';

  SchoolHolidayLocalDataSourceImpl(this._prefs);

  @override
  Future<List<SchoolHoliday>?> getCachedHolidays({
    required String stateCode,
    required int year,
  }) async {
    final key = _getCacheKey(stateCode, year);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) {
      return null;
    }

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => SchoolHoliday.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing the cache, return null
      return null;
    }
  }

  @override
  Future<void> cacheHolidays({
    required String stateCode,
    required int year,
    required List<SchoolHoliday> holidays,
  }) async {
    final key = _getCacheKey(stateCode, year);
    final jsonList = holidays.map((h) => h.toJson()).toList();
    final jsonString = json.encode(jsonList);

    await _prefs.setString(key, jsonString);

    // Update last update time
    final updateKey = _getUpdateKey(stateCode, year);
    await _prefs.setString(updateKey, DateTime.now().toIso8601String());

    // Keep track of all cache keys for clearing
    final keys = _prefs.getStringList(_cacheKeysList) ?? [];
    if (!keys.contains(key)) {
      keys.add(key);
      keys.add(updateKey);
      await _prefs.setStringList(_cacheKeysList, keys);
    }
  }

  @override
  Future<void> clearCache() async {
    final keys = _prefs.getStringList(_cacheKeysList) ?? [];

    for (final key in keys) {
      await _prefs.remove(key);
    }

    await _prefs.remove(_cacheKeysList);
  }

  @override
  Future<DateTime?> getLastUpdateTime({
    required String stateCode,
    required int year,
  }) async {
    final key = _getUpdateKey(stateCode, year);
    final dateString = _prefs.getString(key);

    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  String _getCacheKey(String stateCode, int year) {
    return '$_holidayCachePrefix${stateCode}_$year';
  }

  String _getUpdateKey(String stateCode, int year) {
    return '$_lastUpdatePrefix${stateCode}_$year';
  }
}

/// Implementation of SchoolHolidayLocalDataSource using SQLite database
class SchoolHolidayLocalDataSourceSqliteImpl
    implements SchoolHolidayLocalDataSource {
  final SchoolHolidaysDao _dao;

  SchoolHolidayLocalDataSourceSqliteImpl(this._dao);

  @override
  Future<List<SchoolHoliday>?> getCachedHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      final holidays = await _dao.getHolidays(stateCode: stateCode, year: year);
      return holidays.isNotEmpty ? holidays : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheHolidays({
    required String stateCode,
    required int year,
    required List<SchoolHoliday> holidays,
  }) async {
    await _dao.saveHolidays(
      stateCode: stateCode,
      year: year,
      holidays: holidays,
    );
  }

  @override
  Future<void> clearCache() async {
    await _dao.clearAllHolidays();
  }

  @override
  Future<DateTime?> getLastUpdateTime({
    required String stateCode,
    required int year,
  }) async {
    return await _dao.getLastUpdateTime(stateCode: stateCode, year: year);
  }
}
