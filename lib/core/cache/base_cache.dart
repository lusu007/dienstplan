import 'package:dienstplan/core/utils/logger.dart';

abstract class BaseCache<T> {
  final String cacheName;
  final Duration defaultTtl;
  final int maxSize;

  BaseCache({
    required this.cacheName,
    this.defaultTtl = const Duration(minutes: 30),
    this.maxSize = 100,
  });

  /// Get item from cache
  T? get(String key);

  /// Put item in cache
  void put(String key, T value, {Duration? ttl});

  /// Remove item from cache
  void remove(String key);

  /// Clear all items from cache
  void clear();

  /// Check if cache contains key
  bool contains(String key);

  /// Get cache size
  int get size;

  /// Get cache statistics
  CacheStatistics get statistics;

  /// Log cache operation
  void logOperation(String operation, [dynamic data]) {
    AppLogger.d(
        '$cacheName Cache: $operation ${data != null ? '- $data' : ''}');
  }

  /// Log cache error
  void logError(String operation, dynamic error, dynamic stackTrace) {
    AppLogger.e('$cacheName Cache: Error in $operation', error, stackTrace);
  }
}

class CacheStatistics {
  final int hits;
  final int misses;
  final int size;
  final DateTime lastAccess;

  const CacheStatistics({
    required this.hits,
    required this.misses,
    required this.size,
    required this.lastAccess,
  });

  double get hitRate => hits + misses > 0 ? hits / (hits + misses) : 0.0;

  @override
  String toString() {
    return 'CacheStatistics{hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $size, lastAccess: $lastAccess}';
  }
}
