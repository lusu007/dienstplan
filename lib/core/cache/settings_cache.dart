import 'dart:async';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';

/// Cache for settings to reduce database queries during startup
class SettingsCache {
  static Settings? _cachedSettings;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidity = Duration(minutes: 5);
  static Completer<Settings?>? _loadingCompleter;

  /// Get settings from cache or execute the provided function
  static Future<Settings?> getSettings(
    Future<Settings?> Function() settingsLoader,
  ) async {
    // Check if we have valid cached settings
    if (_cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheValidity) {
      AppLogger.i(
          'SettingsCache: Cache hit - returning cached settings (avoided database query)');
      return _cachedSettings;
    }

    // Debug logging for cache state
    AppLogger.d(
        'SettingsCache: Cache state - cachedSettings: ${_cachedSettings != null}, lastCacheTime: ${_lastCacheTime?.toIso8601String()}, isValid: $isCacheValid');

    // If already loading, wait for the current request to complete
    if (_loadingCompleter != null) {
      AppLogger.i(
          'SettingsCache: Already loading settings, waiting for completion');
      return _loadingCompleter!.future;
    }

    // Start loading
    _loadingCompleter = Completer<Settings?>();
    AppLogger.i('SettingsCache: Cache miss - loading settings from database');

    try {
      final settings = await settingsLoader();

      // Update cache
      _cachedSettings = settings;
      _lastCacheTime = DateTime.now();

      AppLogger.d('SettingsCache: Settings loaded and cached successfully');

      // Complete the loading completer
      _loadingCompleter!.complete(settings);

      return settings;
    } catch (e, stackTrace) {
      AppLogger.e('SettingsCache: Error loading settings', e, stackTrace);

      // Complete the loading completer with error
      _loadingCompleter!.completeError(e, stackTrace);

      rethrow;
    } finally {
      _loadingCompleter = null;
    }
  }

  /// Update the cache with new settings
  static void updateCache(Settings settings) {
    _cachedSettings = settings;
    _lastCacheTime = DateTime.now();
    AppLogger.d('SettingsCache: Cache updated with new settings');
  }

  /// Clear the cache
  static void clearCache() {
    _cachedSettings = null;
    _lastCacheTime = null;
    AppLogger.d('SettingsCache: Cache cleared');
  }

  /// Check if cache is valid
  static bool get isCacheValid {
    return _cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheValidity;
  }

  /// Get cache statistics
  static Map<String, dynamic> get cacheStatistics {
    return {
      'hasCachedSettings': _cachedSettings != null,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'isCacheValid': isCacheValid,
      'isLoading': _loadingCompleter != null,
      'pendingRequests': _loadingCompleter != null ? 1 : 0,
    };
  }
}
