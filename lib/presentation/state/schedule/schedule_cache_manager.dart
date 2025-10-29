import 'dart:async';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

/// Node for LRU doubly-linked list
class _LRUNode {
  final String key;
  _LRUNode? prev;
  _LRUNode? next;

  _LRUNode(this.key);
}

/// Manages intelligent caching of schedule data to reduce database queries
class ScheduleCacheManager {
  final Map<String, List<Schedule>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, DateTime> _lastAccessTimes = {};

  // LRU tracking using doubly-linked list
  final Map<String, _LRUNode> _lruNodes = {};
  _LRUNode? _head;
  _LRUNode? _tail;

  Timer? _cleanupTimer;

  ScheduleCacheManager() {
    _startCleanupTimer();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performCleanup(),
    );
  }

  /// Gets schedules from cache if available and valid
  List<Schedule>? getSchedules(
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) {
    final key = _generateKey(startDate, endDate, configName);
    final now = DateTime.now();

    // Check if cache entry exists and is still valid
    if (!_cache.containsKey(key)) {
      AppLogger.d('ScheduleCacheManager: No cache entry for key $key');
      return null;
    }

    final cacheTime = _cacheTimestamps[key];
    if (cacheTime == null ||
        now.difference(cacheTime) > kCacheValidityDuration) {
      AppLogger.d('ScheduleCacheManager: Cache entry expired for key $key');
      _removeCacheEntry(key);
      return null;
    }

    // Update last access time and LRU position
    _lastAccessTimes[key] = now;
    _moveToHead(key);

    final schedules = _cache[key]!;
    AppLogger.d(
      'ScheduleCacheManager: Cache hit for key $key, returning ${schedules.length} schedules',
    );
    return List.from(schedules);
  }

  /// Stores schedules in cache
  void setSchedules(
    DateTime startDate,
    DateTime endDate,
    String configName,
    List<Schedule> schedules,
  ) {
    final key = _generateKey(startDate, endDate, configName);
    final now = DateTime.now();

    _cache[key] = List.from(schedules);
    _cacheTimestamps[key] = now;
    _lastAccessTimes[key] = now;
    _addToHead(key);

    AppLogger.d(
      'ScheduleCacheManager: Cached ${schedules.length} schedules for key $key',
    );

    // Cleanup if cache is getting too large
    if (_cache.length > kMaxCacheEntries) {
      _performCleanup();
    }
  }

  /// Checks if a date range is cached and valid
  bool isCached(DateTime startDate, DateTime endDate, String configName) {
    final key = _generateKey(startDate, endDate, configName);
    final now = DateTime.now();

    if (!_cache.containsKey(key)) return false;

    final cacheTime = _cacheTimestamps[key];
    return cacheTime != null &&
        now.difference(cacheTime) <= kCacheValidityDuration;
  }

  /// Merges new schedules with existing cached data
  void mergeSchedules(
    DateTime startDate,
    DateTime endDate,
    String configName,
    List<Schedule> newSchedules,
  ) {
    final key = _generateKey(startDate, endDate, configName);
    final now = DateTime.now();

    if (_cache.containsKey(key)) {
      // Merge with existing data using a Map for O(1) deduplication and batched key generation
      final existing = _cache[key]!;
      final scheduleMap = <String, Schedule>{};

      // Add existing schedules to the map
      for (final schedule in existing) {
        final scheduleKey = _generateScheduleKey(schedule);
        scheduleMap[scheduleKey] = schedule;
      }

      // Add new schedules to the map (overwriting duplicates)
      for (final schedule in newSchedules) {
        final scheduleKey = _generateScheduleKey(schedule);
        scheduleMap[scheduleKey] = schedule;
      }

      _cache[key] = scheduleMap.values.toList();
      AppLogger.d(
        'ScheduleCacheManager: Merged schedules for key $key, total: ${_cache[key]!.length}',
      );
    } else {
      // Store new data
      _cache[key] = List.from(newSchedules);
      AppLogger.d(
        'ScheduleCacheManager: Stored new schedules for key $key, count: ${newSchedules.length}',
      );
    }

    _cacheTimestamps[key] = now;
    _lastAccessTimes[key] = now;
    _moveToHead(key);
  }

  /// Clears cache for a specific config
  void clearCacheForConfig(String configName) {
    final keysToRemove = <String>[];

    for (final key in _cache.keys) {
      if (key.contains('_${configName}_')) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _removeCacheEntry(key);
    }

    AppLogger.d(
      'ScheduleCacheManager: Cleared cache for config $configName, removed ${keysToRemove.length} entries',
    );
  }

  /// Clears all cache
  void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
    _lastAccessTimes.clear();
    _lruNodes.clear();
    _head = null;
    _tail = null;
    AppLogger.d('ScheduleCacheManager: Cleared all cache');
  }

  /// Performs cleanup of expired and unused entries
  void _performCleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    // Remove expired entries
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > kCacheValidityDuration) {
        keysToRemove.add(entry.key);
      }
    }

    // Remove old unused entries if cache is still too large
    if (_cache.length > kMaxCacheEntries) {
      final entriesToRemove = _cache.length - kMaxCacheEntries;
      for (int i = 0; i < entriesToRemove && _tail != null; i++) {
        keysToRemove.add(_tail!.key);
        _removeFromTail();
      }
    }

    for (final key in keysToRemove) {
      _removeCacheEntry(key);
    }

    if (keysToRemove.isNotEmpty) {
      AppLogger.d(
        'ScheduleCacheManager: Cleanup removed ${keysToRemove.length} entries',
      );
    }
  }

  void _removeCacheEntry(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _lastAccessTimes.remove(key);
    _removeFromLRU(key);
  }

  String _generateKey(DateTime startDate, DateTime endDate, String configName) {
    // Use StringBuffer for more efficient string concatenation
    // Note: For this specific case with only 3 parts, direct concatenation
    // is actually faster than StringBuffer, so keeping the simple approach
    return '${configName}_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
  }

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int validCount = 0;
    
    for (final timestamp in _cacheTimestamps.values) {
      if (now.difference(timestamp) <= kCacheValidityDuration) {
        validCount++;
      }
    }
    
    DateTime? oldestEntry;
    DateTime? newestEntry;
    
    if (_cacheTimestamps.values.isNotEmpty) {
      for (final timestamp in _cacheTimestamps.values) {
        if (oldestEntry == null || timestamp.isBefore(oldestEntry)) {
          oldestEntry = timestamp;
        }
        if (newestEntry == null || timestamp.isAfter(newestEntry)) {
          newestEntry = timestamp;
        }
      }
    }
    
    return {
      'totalEntries': _cache.length,
      'validEntries': validCount,
      'oldestEntry': oldestEntry,
      'newestEntry': newestEntry,
    };
  }

  void dispose() {
    _cleanupTimer?.cancel();
    clearAll();
  }

  /// Adds a key to the head of the LRU list
  void _addToHead(String key) {
    final node = _LRUNode(key);
    _lruNodes[key] = node;

    if (_head == null) {
      _head = _tail = node;
    } else {
      node.next = _head;
      _head!.prev = node;
      _head = node;
    }
  }

  /// Moves an existing key to the head of the LRU list
  void _moveToHead(String key) {
    final node = _lruNodes[key];
    if (node == null) {
      _addToHead(key);
      return;
    }

    if (node == _head) return; // Already at head

    // Remove from current position
    if (node.prev != null) {
      node.prev!.next = node.next;
    }
    if (node.next != null) {
      node.next!.prev = node.prev;
    }
    if (node == _tail) {
      _tail = node.prev;
    }

    // Add to head
    node.prev = null;
    node.next = _head;
    if (_head != null) {
      _head!.prev = node;
    }
    _head = node;
  }

  /// Removes a key from the LRU list
  void _removeFromLRU(String key) {
    final node = _lruNodes.remove(key);
    if (node == null) return;

    if (node.prev != null) {
      node.prev!.next = node.next;
    }
    if (node.next != null) {
      node.next!.prev = node.prev;
    }
    if (node == _head) {
      _head = node.next;
    }
    if (node == _tail) {
      _tail = node.prev;
    }
  }

  /// Removes the least recently used item from the tail
  void _removeFromTail() {
    if (_tail == null) return;

    final key = _tail!.key;
    _removeFromLRU(key);
  }

  /// Generates a unique key for a schedule to avoid repeated string concatenation
  String _generateScheduleKey(Schedule schedule) {
    return '${schedule.date.toIso8601String()}_${schedule.configName}_${schedule.dutyGroupName}';
  }
}
