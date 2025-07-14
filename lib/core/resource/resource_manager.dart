import 'dart:async';
import 'dart:io';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/dispose/disposable_mixin.dart';

class ResourceManager with DisposableMixin {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  final Map<String, Resource> _resources = {};
  final List<Function> _cleanupCallbacks = [];
  bool _isInitialized = false;

  /// Initialize resource manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.i('ResourceManager: Initializing');

      // Register cleanup callbacks
      _cleanupCallbacks.add(() async {
        await cleanupAllResources();
      });

      _isInitialized = true;
      AppLogger.i('ResourceManager: Initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ResourceManager: Error during initialization', e, stackTrace);
      rethrow;
    }
  }

  /// Register a resource
  void registerResource(String key, Resource resource) {
    checkDisposed();

    if (_resources.containsKey(key)) {
      AppLogger.w(
          'ResourceManager: Resource with key $key already exists, replacing');
      _resources[key]!.dispose();
    }

    _resources[key] = resource;
    AppLogger.d('ResourceManager: Registered resource with key: $key');
  }

  /// Get a resource
  Resource? getResource(String key) {
    checkDisposed();
    return _resources[key];
  }

  /// Unregister a resource
  Future<void> unregisterResource(String key) async {
    checkDisposed();

    final resource = _resources.remove(key);
    if (resource != null) {
      await resource.dispose();
      AppLogger.d('ResourceManager: Unregistered resource with key: $key');
    }
  }

  /// Cleanup all resources
  Future<void> cleanupAllResources() async {
    try {
      AppLogger.i('ResourceManager: Cleaning up all resources');

      final resources = _resources.values.toList();
      _resources.clear();

      for (final resource in resources) {
        try {
          await resource.dispose();
        } catch (e, stackTrace) {
          AppLogger.e(
              'ResourceManager: Error disposing resource', e, stackTrace);
        }
      }

      AppLogger.i('ResourceManager: All resources cleaned up');
    } catch (e, stackTrace) {
      AppLogger.e('ResourceManager: Error during cleanup', e, stackTrace);
    }
  }

  /// Get resource statistics
  Map<String, dynamic> getResourceStatistics() {
    return {
      'totalResources': _resources.length,
      'isInitialized': _isInitialized,
      'resources': _resources.keys.toList(),
    };
  }

  @override
  Future<void> dispose() async {
    await cleanupAllResources();
    await super.dispose();
    AppLogger.i('ResourceManager: Disposed');
  }
}

/// Base class for resources
abstract class Resource with DisposableMixin {
  final String name;
  final DateTime createdAt;
  DateTime? _lastAccessed;

  Resource(this.name) : createdAt = DateTime.now();

  DateTime? get lastAccessed => _lastAccessed;

  /// Update last accessed time
  void updateLastAccessed() {
    _lastAccessed = DateTime.now();
  }

  /// Get resource info
  Map<String, dynamic> getResourceInfo() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessed': _lastAccessed?.toIso8601String(),
      'isDisposed': isDisposed,
    };
  }
}

/// File resource
class FileResource extends Resource {
  final File file;
  final bool autoDelete;

  FileResource(this.file, {this.autoDelete = false}) : super(file.path);

  @override
  Future<void> dispose() async {
    if (autoDelete && file.existsSync()) {
      try {
        await file.delete();
        AppLogger.d('FileResource: Deleted file: ${file.path}');
      } catch (e, stackTrace) {
        AppLogger.e('FileResource: Error deleting file', e, stackTrace);
      }
    }
    await super.dispose();
  }
}

/// Database resource
class DatabaseResource extends Resource {
  final dynamic database;

  DatabaseResource(this.database) : super('Database');

  @override
  Future<void> dispose() async {
    try {
      if (database != null) {
        await database.close();
        AppLogger.d('DatabaseResource: Closed database connection');
      }
    } catch (e, stackTrace) {
      AppLogger.e('DatabaseResource: Error closing database', e, stackTrace);
    }
    await super.dispose();
  }
}

/// Cache resource
class CacheResource extends Resource {
  final dynamic cache;

  CacheResource(this.cache) : super('Cache');

  @override
  Future<void> dispose() async {
    try {
      if (cache != null) {
        cache.clear();
        AppLogger.d('CacheResource: Cleared cache');
      }
    } catch (e, stackTrace) {
      AppLogger.e('CacheResource: Error clearing cache', e, stackTrace);
    }
    await super.dispose();
  }
}

/// Stream resource
class StreamResource extends Resource {
  final StreamSubscription subscription;

  StreamResource(this.subscription) : super('Stream');

  @override
  Future<void> dispose() async {
    try {
      await subscription.cancel();
      AppLogger.d('StreamResource: Cancelled stream subscription');
    } catch (e, stackTrace) {
      AppLogger.e(
          'StreamResource: Error cancelling subscription', e, stackTrace);
    }
    await super.dispose();
  }
}

/// Timer resource
class TimerResource extends Resource {
  final Timer timer;

  TimerResource(this.timer) : super('Timer');

  @override
  Future<void> dispose() async {
    try {
      timer.cancel();
      AppLogger.d('TimerResource: Cancelled timer');
    } catch (e, stackTrace) {
      AppLogger.e('TimerResource: Error cancelling timer', e, stackTrace);
    }
    await super.dispose();
  }
}
