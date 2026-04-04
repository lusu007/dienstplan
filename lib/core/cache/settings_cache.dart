import 'dart:async';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/cache_constants.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';

/// Cache for settings to reduce database queries during startup
class SettingsCache {
  static Settings? _cachedSettings;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidity = kSettingsCacheTtl;
  static const Duration _startupCacheValidity =
      kSettingsStartupCacheTtl; // More aggressive during startup
  static Completer<Result<Settings?>>? _loadingCompleter;
  static bool _isStartupPhase = true;

  /// Get settings from cache or execute the provided loader ([Result] from repository).
  static Future<Result<Settings?>> getSettings(
    Future<Result<Settings?>> Function() settingsLoader,
  ) async {
    final cacheValidity = _isStartupPhase
        ? _startupCacheValidity
        : _cacheValidity;
    final isValid =
        _cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < cacheValidity;

    if (isValid) {
      AppLogger.d(
        'SettingsCache: Cache hit - returning cached settings (avoided database query)',
      );
      return Result.success<Settings?>(_cachedSettings);
    }

    AppLogger.d(
      'SettingsCache: Cache state - cachedSettings: ${_cachedSettings != null}, lastCacheTime: ${_lastCacheTime?.toIso8601String()}, isValid: $isValid, isStartupPhase: $_isStartupPhase',
    );

    if (_loadingCompleter != null) {
      AppLogger.d(
        'SettingsCache: Already loading settings, waiting for completion',
      );
      return _loadingCompleter!.future;
    }

    _loadingCompleter = Completer<Result<Settings?>>();
    AppLogger.d('SettingsCache: Cache miss - loading settings from database');

    try {
      final Result<Settings?> loaded = await settingsLoader();
      if (loaded.isSuccess) {
        _cachedSettings = loaded.valueIfSuccess;
        _lastCacheTime = DateTime.now();
        AppLogger.d('SettingsCache: Settings loaded and cached successfully');
      } else {
        AppLogger.d(
          'SettingsCache: Settings load failed, not updating cache (failure=${loaded.failure.code})',
        );
      }
      _loadingCompleter!.complete(loaded);
      return loaded;
    } catch (e, stackTrace) {
      AppLogger.e('SettingsCache: Error loading settings', e, stackTrace);
      final Result<Settings?> failure = Result.createFailure<Settings?>(
        UnknownFailure(
          technicalMessage: 'Settings cache load error: $e',
          cause: e,
          stackTrace: stackTrace,
        ),
      );
      _loadingCompleter!.complete(failure);
      return failure;
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
      'SettingsCache: Startup phase ended, switching to normal cache validity',
    );
  }

  /// Check if cache is valid
  static bool get isCacheValid {
    final cacheValidity = _isStartupPhase
        ? _startupCacheValidity
        : _cacheValidity;
    return _cachedSettings != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < cacheValidity;
  }

  /// Get cache statistics
  static Map<String, dynamic> get cacheStatistics {
    final cacheValidity = _isStartupPhase
        ? _startupCacheValidity
        : _cacheValidity;
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
