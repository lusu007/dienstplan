import 'dart:async';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/cache_constants.dart';

/// Cache for settings to reduce database queries during startup
class SettingsCache {
  static Settings? _cachedSettings;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidity = kSettingsCacheTtl;
  static const Duration _startupCacheValidity =
      kSettingsStartupCacheTtl; // More aggressive during startup
  static Completer<Settings?>? _loadingCompleter;
  static bool _isStartupPhase = true;

  /// Get settings from cache or execute the provided function
  static Future<Settings?> getSettings(
    Future<Settings?> Function() settingsLoader,
  ) async {
    // Check if we have valid cached settings
    final cacheValidity =
        _isStartupPhase ? _startupCacheValidity : _cacheValidity;
    final isValid = _cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < cacheValidity;

    if (isValid) {
      AppLogger.i(
          'SettingsCache: Cache hit - returning cached settings (avoided database query)');
      return _cachedSettings;
    }

    // Debug logging for cache state
    AppLogger.d(
        'SettingsCache: Cache state - cachedSettings: ${_cachedSettings != null}, lastCacheTime: ${_lastCacheTime?.toIso8601String()}, isValid: $isValid, isStartupPhase: $_isStartupPhase');

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

  /// End startup phase and switch to normal cache validity
  static void endStartupPhase() {
    _isStartupPhase = false;
    AppLogger.i(
        'SettingsCache: Startup phase ended, switching to normal cache validity');
  }

  /// Check if cache is valid
  static bool get isCacheValid {
    final cacheValidity =
        _isStartupPhase ? _startupCacheValidity : _cacheValidity;
    return _cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < cacheValidity;
  }

  /// Get cache statistics
  static Map<String, dynamic> get cacheStatistics {
    final cacheValidity =
        _isStartupPhase ? _startupCacheValidity : _cacheValidity;
    return {
      'hasCachedSettings': _cachedSettings != null,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'isCacheValid': isCacheValid,
      'isStartupPhase': _isStartupPhase,
      'cacheValidity': cacheValidity.inSeconds,
      'isLoading': _loadingCompleter != null,
      'pendingRequests': _loadingCompleter != null ? 1 : 0,
    };
  }
}
