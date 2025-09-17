import 'package:dienstplan/core/cache/base_cache.dart';
import 'package:dienstplan/core/utils/logger.dart';

abstract class CachedUseCase<Input, Output> {
  final BaseCache<Output> cache;
  final String useCaseName;

  CachedUseCase({required this.cache, required this.useCaseName});

  /// Execute the use case with caching
  Future<Output> execute(Input input) async {
    final cacheKey = _generateCacheKey(input);

    // Try to get from cache first
    final cachedResult = cache.get(cacheKey);
    if (cachedResult != null) {
      AppLogger.d('$useCaseName: Cache hit for key: $cacheKey');
      return cachedResult;
    }

    AppLogger.d('$useCaseName: Cache miss for key: $cacheKey');

    // Execute the actual use case logic
    final result = await performExecution(input);

    // Cache the result
    cache.put(cacheKey, result);

    return result;
  }

  /// Execute without caching (for force refresh)
  Future<Output> executeWithoutCache(Input input) async {
    final result = await performExecution(input);
    return result;
  }

  /// Clear cache for specific input
  void clearCache(Input input) {
    final cacheKey = _generateCacheKey(input);
    cache.remove(cacheKey);
    AppLogger.d('$useCaseName: Cleared cache for key: $cacheKey');
  }

  /// Clear all cache
  void clearAllCache() {
    cache.clear();
    AppLogger.d('$useCaseName: Cleared all cache');
  }

  /// Get cache statistics
  CacheStatistics get cacheStatistics => cache.statistics;

  /// Generate cache key from input
  String _generateCacheKey(Input input) {
    return '${useCaseName}_${input.hashCode}';
  }

  /// Perform the actual execution logic (to be implemented by subclasses)
  Future<Output> performExecution(Input input);
}

/// Cached use case for operations that don't need input
abstract class CachedUseCaseNoInput<Output> {
  final BaseCache<Output> cache;
  final String useCaseName;

  CachedUseCaseNoInput({required this.cache, required this.useCaseName});

  /// Execute the use case with caching
  Future<Output> execute() async {
    const cacheKey = 'no_input';

    // Try to get from cache first
    final cachedResult = cache.get(cacheKey);
    if (cachedResult != null) {
      AppLogger.d('$useCaseName: Cache hit');
      return cachedResult;
    }

    AppLogger.d('$useCaseName: Cache miss');

    // Execute the actual use case logic
    final result = await performExecution();

    // Cache the result
    cache.put(cacheKey, result);

    return result;
  }

  /// Execute without caching (for force refresh)
  Future<Output> executeWithoutCache() async {
    final result = await performExecution();
    return result;
  }

  /// Clear cache
  void clearCache() {
    cache.clear();
    AppLogger.d('$useCaseName: Cleared cache');
  }

  /// Get cache statistics
  CacheStatistics get cacheStatistics => cache.statistics;

  /// Perform the actual execution logic (to be implemented by subclasses)
  Future<Output> performExecution();
}
