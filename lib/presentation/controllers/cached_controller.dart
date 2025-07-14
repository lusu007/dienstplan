import 'package:flutter/foundation.dart';
import 'package:dienstplan/core/cache/base_cache.dart';
import 'package:dienstplan/core/utils/logger.dart';

abstract class CachedController extends ChangeNotifier {
  final BaseCache<dynamic> cache;
  final String controllerName;
  bool _isLoading = false;
  String? _error;

  CachedController({
    required this.cache,
    required this.controllerName,
  });

  bool get isLoading => _isLoading;
  String? get error => _error;
  CacheStatistics get cacheStatistics => cache.statistics;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    setError(null);
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    return cache.get(key) as T?;
  }

  /// Put data in cache
  void putCachedData<T>(String key, T data, {Duration? ttl}) {
    cache.put(key, data, ttl: ttl);
  }

  /// Remove cached data
  void removeCachedData(String key) {
    cache.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    cache.clear();
    AppLogger.d('$controllerName: Cleared all cache');
  }

  /// Generate cache key
  String generateCacheKey(String operation,
      [Map<String, dynamic>? parameters]) {
    if (parameters == null || parameters.isEmpty) {
      return '${controllerName}_$operation';
    }

    final sortedParams = parameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final paramString =
        sortedParams.map((e) => '${e.key}:${e.value}').join('_');

    return '${controllerName}_${operation}_$paramString';
  }

  /// Execute operation with caching
  Future<T> executeWithCache<T>(
    String operation,
    Future<T> Function() operationFunction, {
    Map<String, dynamic>? parameters,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    final cacheKey = generateCacheKey(operation, parameters);

    if (!forceRefresh) {
      final cachedResult = getCachedData<T>(cacheKey);
      if (cachedResult != null) {
        AppLogger.d('$controllerName: Cache hit for $operation');
        return cachedResult;
      }
    }

    AppLogger.d('$controllerName: Cache miss for $operation');

    setLoading(true);
    clearError();

    try {
      final result = await operationFunction();
      putCachedData(cacheKey, result, ttl: ttl);
      return result;
    } catch (e, stackTrace) {
      final errorMessage = 'Error in $operation: $e';
      setError(errorMessage);
      AppLogger.e('$controllerName: $errorMessage', e, stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Execute operation without caching
  Future<T> executeWithoutCache<T>(
    String operation,
    Future<T> Function() operationFunction,
  ) async {
    setLoading(true);
    clearError();

    try {
      final result = await operationFunction();
      return result;
    } catch (e, stackTrace) {
      final errorMessage = 'Error in $operation: $e';
      setError(errorMessage);
      AppLogger.e('$controllerName: $errorMessage', e, stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Refresh cached data
  Future<T> refreshCachedData<T>(
    String operation,
    Future<T> Function() operationFunction, {
    Map<String, dynamic>? parameters,
    Duration? ttl,
  }) async {
    return executeWithCache(
      operation,
      operationFunction,
      parameters: parameters,
      ttl: ttl,
      forceRefresh: true,
    );
  }

  @override
  void dispose() {
    AppLogger.d('$controllerName: Disposing controller');
    super.dispose();
  }
}
