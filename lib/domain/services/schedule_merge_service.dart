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
    if (existing.isEmpty) return List<Schedule>.from(incoming);
    if (incoming.isEmpty) return List<Schedule>.from(existing);

    // O(n + m) using map keyed by composite schedule identity
    final Map<String, Schedule> byKey = <String, Schedule>{};
    for (final Schedule s in existing) {
      byKey[_keyOf(s)] = s;
    }
    for (final Schedule s in incoming) {
      byKey[_keyOf(s)] = s; // replace or insert
    }
    return byKey.values.toList(growable: false);
  }

  List<Schedule> mergeOutsideRange({
    required List<Schedule> existing,
    required List<Schedule> incoming,
    required DateRange range,
  }) {
    final Map<String, Schedule> mergedMap = <String, Schedule>{};
    
    // Add existing items that are outside the range
    for (final Schedule oldItem in existing) {
      if (!range.containsDate(oldItem.date)) {
        mergedMap[_keyOf(oldItem)] = oldItem;
      }
    }
    
    // Add incoming items, using map to avoid O(n*m) complexity
    for (final Schedule newItem in incoming) {
      mergedMap[_keyOf(newItem)] = newItem;
    }
    
    return mergedMap.values.toList(growable: false);
  }

  // Merge that preserves existing items inside range for other configs,
  // and replaces only items belonging to the given replaceConfigName.
  List<Schedule> mergeReplacingConfigInRange({
    required List<Schedule> existing,
    required List<Schedule> incoming,
    required DateRange range,
    required String replaceConfigName,
  }) {
    // Build a set of keys to replace inside the range for the given config
    final Set<String> replaceKeys = <String>{};
    for (final Schedule s in incoming) {
      if (s.configName == replaceConfigName && range.containsDate(s.date)) {
        replaceKeys.add(_keyOf(s));
      }
    }

    final Map<String, Schedule> result = <String, Schedule>{};
    for (final Schedule s in existing) {
      final bool inRange = range.containsDate(s.date);
      if (!(inRange && s.configName == replaceConfigName)) {
        // keep all outside the replace window or different config
        result[_keyOf(s)] = s;
      }
    }
    for (final Schedule s in incoming) {
      result[_keyOf(s)] = s;
    }
    return result.values.toList(growable: false);
  }

  List<Schedule> deduplicate(List<Schedule> schedules) {
    if (schedules.isEmpty) return const <Schedule>[];
    final Map<String, Schedule> byKey = <String, Schedule>{};
    for (final Schedule s in schedules) {
      byKey[_keyOf(s)] = s;
    }
    return byKey.values.toList(growable: false);
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

  String _keyOf(Schedule s) {
    final DateTime d = s.date;
    return '${d.year}-${d.month}-${d.day}|${s.configName}|${s.dutyGroupName}|${s.dutyTypeId}|${s.service}';
  }

  /// Checks if the schedules list is already sorted by date in ascending order
  /// Performs early termination for better average-case performance
  bool _isAlreadySorted(List<Schedule> schedules) {
    if (schedules.length <= 1) return true;

    // Sample-based approach for large lists (10% sample)
    // If sample is sorted, assume list is sorted to avoid O(n) check
    if (schedules.length > 100) {
      final sampleSize = (schedules.length * 0.1).toInt();
      final step = schedules.length ~/ sampleSize;
      
      for (int i = step; i < schedules.length; i += step) {
        if (schedules[i - step].date.isAfter(schedules[i].date)) {
          return false;
        }
      }
      return true; // Sample indicates sorted
    }

    // Full check for smaller lists
    for (int i = 1; i < schedules.length; i++) {
      if (schedules[i - 1].date.isAfter(schedules[i].date)) {
        return false;
      }
    }
    return true;
  }
}
