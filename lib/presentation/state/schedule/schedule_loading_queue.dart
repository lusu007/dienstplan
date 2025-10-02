import 'dart:async';
import 'package:dienstplan/core/utils/logger.dart';

/// Manages a queue of schedule loading operations to prevent overlapping requests
class ScheduleLoadingQueue {
  final Map<String, Completer<void>> _pendingOperations = {};
  final Set<String> _loadingKeys = {};

  /// Executes a loading operation if not already in progress
  /// Returns true if the operation was queued, false if it was already pending
  Future<bool> executeIfNotPending(
    String operationKey,
    Future<void> Function() operation,
  ) async {
    // Check if already loading
    if (_loadingKeys.contains(operationKey)) {
      AppLogger.d(
        'ScheduleLoadingQueue: Operation $operationKey already in progress, waiting...',
      );
      // Wait for the existing operation to complete
      if (_pendingOperations.containsKey(operationKey)) {
        await _pendingOperations[operationKey]!.future;
      }
      return false;
    }

    // Check if already pending
    if (_pendingOperations.containsKey(operationKey)) {
      AppLogger.d(
        'ScheduleLoadingQueue: Operation $operationKey already pending, waiting...',
      );
      await _pendingOperations[operationKey]!.future;
      return false;
    }

    // Create new operation
    final completer = Completer<void>();
    _pendingOperations[operationKey] = completer;
    _loadingKeys.add(operationKey);

    AppLogger.d('ScheduleLoadingQueue: Starting operation $operationKey');

    try {
      await operation();
      AppLogger.d('ScheduleLoadingQueue: Completed operation $operationKey');
    } catch (e) {
      AppLogger.e('ScheduleLoadingQueue: Error in operation $operationKey', e);
      rethrow;
    } finally {
      _loadingKeys.remove(operationKey);
      _pendingOperations.remove(operationKey);
      completer.complete();
    }

    return true;
  }

  /// Generates a unique key for a date range and config combination
  String generateOperationKey(
    DateTime startDate,
    DateTime endDate,
    String configName,
  ) {
    return '${configName}_${startDate.toIso8601String()}_${endDate.toIso8601String()}';
  }

  /// Generates a key for a month and config combination
  String generateMonthOperationKey(DateTime month, String configName) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return generateOperationKey(startDate, endDate, configName);
  }

  /// Cancels all pending operations
  void cancelAll() {
    AppLogger.d('ScheduleLoadingQueue: Canceling all pending operations');
    for (final completer in _pendingOperations.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Operation cancelled by cancelAll()'),
        );
      }
    }
    _pendingOperations.clear();
    _loadingKeys.clear();
  }

  /// Gets the number of pending operations
  int get pendingCount => _pendingOperations.length;

  /// Gets the number of currently loading operations
  int get loadingCount => _loadingKeys.length;
}
