import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/core/utils/logger.dart';

/// Optimizes UI updates by batching state changes and reducing unnecessary rebuilds
class ScheduleUiOptimizer {
  Timer? _batchTimer;
  final Set<String> _pendingUpdates = {};
  final Map<String, dynamic> _pendingStateChanges = {};

  /// Batches multiple state updates into a single UI update
  void batchUpdate(
    String updateKey,
    dynamic stateChange,
    VoidCallback onUpdate,
  ) {
    _pendingUpdates.add(updateKey);
    _pendingStateChanges[updateKey] = stateChange;

    AppLogger.d('ScheduleUiOptimizer: Batched update $updateKey');

    // Only schedule a new batch update if one is not already scheduled
    if (_batchTimer?.isActive != true) {
      _batchTimer = Timer(kBatchDelay, () {
        if (_pendingUpdates.isNotEmpty) {
          AppLogger.d(
            'ScheduleUiOptimizer: Executing ${_pendingUpdates.length} batched updates',
          );
          onUpdate();
          _pendingUpdates.clear();
          _pendingStateChanges.clear();
        }
        _batchTimer = null;
      });
    }
  }

  /// Immediately executes an update, canceling any pending batch
  void executeImmediately(
    String updateKey,
    dynamic stateChange,
    VoidCallback onUpdate,
  ) {
    _batchTimer?.cancel();
    _pendingUpdates.clear();
    _pendingStateChanges.clear();

    AppLogger.d('ScheduleUiOptimizer: Executing immediate update $updateKey');
    onUpdate();
  }

  /// Checks if an update is pending
  bool isUpdatePending(String updateKey) {
    return _pendingUpdates.contains(updateKey);
  }

  /// Gets pending state changes
  Map<String, dynamic> getPendingChanges() {
    return Map.from(_pendingStateChanges);
  }

  /// Cancels all pending updates
  void cancelPendingUpdates() {
    _batchTimer?.cancel();
    _pendingUpdates.clear();
    _pendingStateChanges.clear();
    AppLogger.d('ScheduleUiOptimizer: Cancelled all pending updates');
  }

  void dispose() {
    _batchTimer?.cancel();
    _pendingUpdates.clear();
    _pendingStateChanges.clear();
  }
}

/// Mixin for widgets that need optimized state management
mixin ScheduleUiOptimizationMixin<T extends StatefulWidget> on State<T> {
  final ScheduleUiOptimizer _uiOptimizer = ScheduleUiOptimizer();

  @override
  void dispose() {
    _uiOptimizer.dispose();
    super.dispose();
  }

  /// Batches a state update
  void batchStateUpdate(String updateKey, dynamic stateChange) {
    _uiOptimizer.batchUpdate(updateKey, stateChange, () => setState(() {}));
  }

  /// Immediately executes a state update
  void executeStateUpdate(String updateKey, dynamic stateChange) {
    _uiOptimizer.executeImmediately(
      updateKey,
      stateChange,
      () => setState(() {}),
    );
  }
}
