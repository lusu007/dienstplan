import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dienstplan/core/utils/logger.dart';

/// Debounces navigation operations to prevent excessive loading during rapid month changes
class ScheduleNavigationDebouncer {
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  /// Debounces a navigation operation
  /// Returns true if the operation should proceed, false if it was debounced
  bool debounceNavigation(String operation, VoidCallback callback) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    AppLogger.d('ScheduleNavigationDebouncer: Debouncing $operation');

    _debounceTimer = Timer(_debounceDelay, () {
      AppLogger.d(
        'ScheduleNavigationDebouncer: Executing debounced $operation',
      );
      callback();
    });

    return false; // Operation was debounced
  }

  /// Immediately executes an operation, canceling any pending debounced operations
  void executeImmediately(String operation, VoidCallback callback) {
    _debounceTimer?.cancel();
    AppLogger.d(
      'ScheduleNavigationDebouncer: Executing immediately $operation',
    );
    callback();
  }

  /// Cancels any pending debounced operations
  void cancelPending() {
    if (_debounceTimer?.isActive == true) {
      AppLogger.d('ScheduleNavigationDebouncer: Canceling pending operations');
      _debounceTimer?.cancel();
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
