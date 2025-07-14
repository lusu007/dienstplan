import 'dart:async';
import 'package:dienstplan/core/utils/logger.dart';

mixin DisposableMixin {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<Function> _disposeCallbacks = [];
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  /// Add a stream subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    if (!_isDisposed) {
      _subscriptions.add(subscription);
    } else {
      subscription.cancel();
    }
  }

  /// Add a timer for automatic disposal
  void addTimer(Timer timer) {
    if (!_isDisposed) {
      _timers.add(timer);
    } else {
      timer.cancel();
    }
  }

  /// Add a dispose callback
  void addDisposeCallback(Function callback) {
    if (!_isDisposed) {
      _disposeCallbacks.add(callback);
    } else {
      callback();
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      // Cancel all timers
      for (final timer in _timers) {
        timer.cancel();
      }
      _timers.clear();

      // Cancel all subscriptions
      for (final subscription in _subscriptions) {
        await subscription.cancel();
      }
      _subscriptions.clear();

      // Execute dispose callbacks
      for (final callback in _disposeCallbacks) {
        try {
          callback();
        } catch (e, stackTrace) {
          AppLogger.e('Error in dispose callback', e, stackTrace);
        }
      }
      _disposeCallbacks.clear();

      AppLogger.d('${runtimeType.toString()}: Disposed successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Error during disposal', e, stackTrace);
    }
  }

  /// Check if disposed before performing operations
  void checkDisposed() {
    if (_isDisposed) {
      throw StateError('${runtimeType.toString()} has been disposed');
    }
  }
}

/// Base class for disposable objects
abstract class Disposable with DisposableMixin {
  // All methods are inherited from DisposableMixin
}
