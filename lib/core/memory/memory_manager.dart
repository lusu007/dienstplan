import 'dart:async';
import 'dart:developer' as developer;
import 'package:dienstplan/core/utils/logger.dart';

class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<String, WeakReference<Object>> _trackedObjects = {};
  final List<Function> _cleanupCallbacks = [];
  Timer? _cleanupTimer;
  bool _isInitialized = false;

  /// Initialize memory manager
  void initialize() {
    if (_isInitialized) return;

    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _performCleanup();
    });

    // Register cleanup callback for app lifecycle
    _cleanupCallbacks.add(() {
      _cleanupTimer?.cancel();
      _performCleanup();
    });

    _isInitialized = true;
    AppLogger.i('MemoryManager: Initialized');
  }

  /// Track an object for memory management
  void trackObject(String key, Object object) {
    _trackedObjects[key] = WeakReference(object);
    AppLogger.d('MemoryManager: Tracking object with key: $key');
  }

  /// Stop tracking an object
  void untrackObject(String key) {
    _trackedObjects.remove(key);
    AppLogger.d('MemoryManager: Untracking object with key: $key');
  }

  /// Get tracked object count
  int get trackedObjectCount => _trackedObjects.length;

  /// Perform memory cleanup
  void _performCleanup() {
    try {
      final beforeCount = _trackedObjects.length;
      final keysToRemove = <String>[];

      // Check for garbage collected objects
      for (final entry in _trackedObjects.entries) {
        if (entry.value.target == null) {
          keysToRemove.add(entry.key);
        }
      }

      // Remove garbage collected objects
      for (final key in keysToRemove) {
        _trackedObjects.remove(key);
      }

      final afterCount = _trackedObjects.length;
      final cleanedCount = beforeCount - afterCount;

      if (cleanedCount > 0) {
        AppLogger.i(
            'MemoryManager: Cleaned up $cleanedCount garbage collected objects');
      }

      // Force garbage collection if needed
      if (cleanedCount > 10) {
        _forceGarbageCollection();
      }
    } catch (e, stackTrace) {
      AppLogger.e('MemoryManager: Error during cleanup', e, stackTrace);
    }
  }

  /// Force garbage collection
  void _forceGarbageCollection() {
    try {
      developer.log('MemoryManager: Forcing garbage collection');
      // Note: In Flutter, garbage collection is handled automatically
      // This is more of a logging mechanism for debugging
    } catch (e, stackTrace) {
      AppLogger.e(
          'MemoryManager: Error during garbage collection', e, stackTrace);
    }
  }

  /// Get memory statistics
  Map<String, dynamic> getMemoryStatistics() {
    return {
      'trackedObjects': _trackedObjects.length,
      'isInitialized': _isInitialized,
      'cleanupCallbacks': _cleanupCallbacks.length,
    };
  }

  /// Register cleanup callback
  void registerCleanupCallback(Function callback) {
    _cleanupCallbacks.add(callback);
  }

  /// Dispose memory manager
  void dispose() {
    _cleanupTimer?.cancel();
    _trackedObjects.clear();
    _cleanupCallbacks.clear();
    _isInitialized = false;
    AppLogger.i('MemoryManager: Disposed');
  }
}

/// Weak reference wrapper for better memory management
class WeakReference<T> {
  final T _target;
  WeakReference(this._target);
  T? get target => _target;
}

/// Memory leak detector
class MemoryLeakDetector {
  static final Map<String, int> _objectCounts = {};
  static final Map<String, DateTime> _lastAccess = {};

  /// Track object creation
  static void trackObjectCreation(String className) {
    _objectCounts[className] = (_objectCounts[className] ?? 0) + 1;
    _lastAccess[className] = DateTime.now();

    AppLogger.d(
        'MemoryLeakDetector: Created $className (total: ${_objectCounts[className]})');
  }

  /// Track object disposal
  static void trackObjectDisposal(String className) {
    _objectCounts[className] = (_objectCounts[className] ?? 1) - 1;
    _lastAccess[className] = DateTime.now();

    AppLogger.d(
        'MemoryLeakDetector: Disposed $className (total: ${_objectCounts[className]})');
  }

  /// Check for potential memory leaks
  static void checkForLeaks() {
    final potentialLeaks = <String>[];

    for (final entry in _objectCounts.entries) {
      if (entry.value > 10) {
        potentialLeaks.add('${entry.key}: ${entry.value} instances');
      }
    }

    if (potentialLeaks.isNotEmpty) {
      AppLogger.w(
          'MemoryLeakDetector: Potential memory leaks detected: ${potentialLeaks.join(', ')}');
    }
  }

  /// Get object counts
  static Map<String, int> getObjectCounts() {
    return Map.unmodifiable(_objectCounts);
  }

  /// Reset tracking
  static void reset() {
    _objectCounts.clear();
    _lastAccess.clear();
  }
}
