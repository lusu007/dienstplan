import 'package:dienstplan/core/cache/base_cache.dart';

class CacheEntry<T> {
  final T value;
  final DateTime expiryTime;

  CacheEntry(this.value, Duration ttl) : expiryTime = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class MemoryCache<T> extends BaseCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  int _hits = 0;
  int _misses = 0;
  DateTime _lastAccess = DateTime.now();

  MemoryCache({required super.cacheName, super.defaultTtl, super.maxSize});

  @override
  T? get(String key) {
    _lastAccess = DateTime.now();

    if (!_cache.containsKey(key)) {
      _misses++;
      logOperation('miss', key);
      return null;
    }

    final entry = _cache[key]!;
    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      logOperation('expired', key);
      return null;
    }

    _hits++;
    logOperation('hit', key);
    return entry.value;
  }

  @override
  void put(String key, T value, {Duration? ttl}) {
    _lastAccess = DateTime.now();

    // Remove oldest entries if cache is full
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _evictOldest();
    }

    final entry = CacheEntry<T>(value, ttl ?? defaultTtl);
    _cache[key] = entry;
    logOperation('put', key);
  }

  @override
  void remove(String key) {
    _cache.remove(key);
    logOperation('remove', key);
  }

  @override
  void clear() {
    _cache.clear();
    logOperation('clear');
  }

  @override
  bool contains(String key) {
    if (!_cache.containsKey(key)) return false;

    final entry = _cache[key]!;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  @override
  int get size => _cache.length;

  @override
  CacheStatistics get statistics {
    return CacheStatistics(
      hits: _hits,
      misses: _misses,
      size: _cache.length,
      lastAccess: _lastAccess,
    );
  }

  void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.expiryTime.isBefore(oldestTime)) {
        oldestTime = entry.value.expiryTime;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      logOperation('evict', oldestKey);
    }
  }

  /// Clean up expired entries
  void cleanup() {
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      logOperation('cleanup', '${expiredKeys.length} expired entries');
    }
  }

  /// Get all keys in cache
  Set<String> get keys => _cache.keys.toSet();

  /// Get all values in cache
  List<T> get values => _cache.values.map((entry) => entry.value).toList();
}
