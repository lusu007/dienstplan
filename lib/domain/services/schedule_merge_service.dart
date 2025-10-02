import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';

class ScheduleMergeService {
  // Upsert by unique schedule key (date + dutyGroup + config):
  // - Keeps all existing items not present in incoming
  // - Replaces existing matches with incoming
  List<Schedule> upsertByKey({
    required List<Schedule> existing,
    required List<Schedule> incoming,
  }) {
    final List<Schedule> result = <Schedule>[];
    for (final Schedule oldItem in existing) {
      final bool willBeReplaced = incoming.any(
        (Schedule inc) => _isSameScheduleDayAndGroup(inc, oldItem),
      );
      if (!willBeReplaced) {
        result.add(oldItem);
      }
    }
    result.addAll(incoming);
    return result;
  }

  List<Schedule> mergeOutsideRange({
    required List<Schedule> existing,
    required List<Schedule> incoming,
    required DateRange range,
  }) {
    final List<Schedule> merged = <Schedule>[];
    for (final Schedule oldItem in existing) {
      if (!range.containsDate(oldItem.date)) {
        merged.add(oldItem);
      }
    }
    for (final Schedule newItem in incoming) {
      final bool exists = merged.any(
        (Schedule s) => _isSameScheduleDayAndGroup(s, newItem),
      );
      if (!exists) {
        merged.add(newItem);
      }
    }
    return merged;
  }

  // Merge that preserves existing items inside range for other configs,
  // and replaces only items belonging to the given replaceConfigName.
  List<Schedule> mergeReplacingConfigInRange({
    required List<Schedule> existing,
    required List<Schedule> incoming,
    required DateRange range,
    required String replaceConfigName,
  }) {
    final List<Schedule> merged = <Schedule>[];
    for (final Schedule oldItem in existing) {
      final bool isInsideRange = range.containsDate(oldItem.date);
      final bool isSameConfig = oldItem.configName == replaceConfigName;
      if (!isInsideRange) {
        merged.add(oldItem);
        continue;
      }
      // Inside range: keep only if it belongs to a different config
      if (!isSameConfig) {
        // Avoid duplicates with incoming
        final bool willBeAddedByIncoming = incoming.any(
          (Schedule inc) =>
              _isSameScheduleDayAndGroup(inc, oldItem) &&
              inc.configName == oldItem.configName,
        );
        if (!willBeAddedByIncoming) {
          merged.add(oldItem);
        }
      }
    }
    for (final Schedule newItem in incoming) {
      final bool exists = merged.any(
        (Schedule s) =>
            _isSameScheduleDayAndGroup(s, newItem) &&
            s.configName == newItem.configName,
      );
      if (!exists) {
        merged.add(newItem);
      }
    }
    return merged;
  }

  List<Schedule> deduplicate(List<Schedule> schedules) {
    final List<Schedule> result = <Schedule>[];
    for (final Schedule s in schedules) {
      final bool exists = result.any(
        (Schedule e) => _isSameScheduleDayAndGroup(e, s),
      );
      if (!exists) {
        result.add(s);
      }
    }
    return result;
  }

  /// Removes schedules outside the specified date range to prevent memory accumulation
  /// Always preserves the month containing the selected day ±1 month for off days
  List<Schedule> cleanupOldSchedules({
    required List<Schedule> schedules,
    required DateTime currentDate,
    required int monthsToKeep,
    DateTime? selectedDay,
  }) {
    if (schedules.isEmpty) return [];

    // Sort schedules by date ascending (only if not already sorted)
    List<Schedule> sortedSchedules;
    if (_isAlreadySorted(schedules)) {
      sortedSchedules = schedules;
    } else {
      sortedSchedules = List<Schedule>.from(schedules)
        ..sort((a, b) => a.date.compareTo(b.date));
    }

    final DateTime cutoffDate = DateTime(
      currentDate.year,
      currentDate.month - monthsToKeep,
      1,
    );

    // Binary search for cutoffDate
    final int cutoffIdx = _lowerBound(sortedSchedules, cutoffDate);

    // Collect indices to keep
    final Set<int> keepIndices = <int>{};

    // Keep all schedules after or at cutoffDate
    for (int i = cutoffIdx; i < sortedSchedules.length; i++) {
      keepIndices.add(i);
    }

    // If there's a selected day, ensure its month ±1 is always preserved
    if (selectedDay != null) {
      final selectedMonth = DateTime(selectedDay.year, selectedDay.month, 1);
      final selectedMonthStart = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
        1,
      );
      // selectedMonthEnd is the last day of the month after selectedMonth
      final selectedMonthEnd = DateTime(
        selectedMonth.year,
        selectedMonth.month + 2,
        0,
      );

      // Find lower and upper bounds for the selected month window
      final int startIdx = _lowerBound(sortedSchedules, selectedMonthStart);
      final int endIdx = _upperBound(sortedSchedules, selectedMonthEnd);

      for (int i = startIdx; i < endIdx; i++) {
        keepIndices.add(i);
      }
    }

    // Return only the kept schedules, preserving original order as much as possible
    final sortedIndices = keepIndices.toList()..sort();
    return sortedIndices.map((i) => sortedSchedules[i]).toList();
  }

  /// Returns the first index where schedule.date >= target
  int _lowerBound(List<Schedule> schedules, DateTime target) {
    int low = 0;
    int high = schedules.length;
    while (low < high) {
      final int mid = low + ((high - low) >> 1);
      if (schedules[mid].date.isBefore(target)) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// Returns the first index where schedule.date > target
  int _upperBound(List<Schedule> schedules, DateTime target) {
    int low = 0;
    int high = schedules.length;
    while (low < high) {
      final int mid = low + ((high - low) >> 1);
      if (!schedules[mid].date.isAfter(target)) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  bool _isSameScheduleDayAndGroup(Schedule a, Schedule b) {
    return a.date.year == b.date.year &&
        a.date.month == b.date.month &&
        a.date.day == b.date.day &&
        a.dutyGroupName == b.dutyGroupName &&
        a.configName == b.configName;
  }

  /// Checks if the schedules list is already sorted by date in ascending order
  bool _isAlreadySorted(List<Schedule> schedules) {
    if (schedules.length <= 1) return true;

    for (int i = 1; i < schedules.length; i++) {
      if (schedules[i - 1].date.isAfter(schedules[i].date)) {
        return false;
      }
    }
    return true;
  }
}
