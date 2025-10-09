import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';

/// Optimized index for efficient schedule range queries.
///
/// This class provides O(k) coverage checks and O(log n) binary search
/// for optimal performance when checking if schedules exist for date ranges.
class ScheduleIndex {
  final Map<String, List<DateRange>> _coverageRanges;
  final Map<String, List<Schedule>> _schedulesByConfig;
  final Map<String, List<Schedule>> _sortedByConfig;

  /// Default constructor for creating an empty index.
  const ScheduleIndex()
    : _coverageRanges = const {},
      _schedulesByConfig = const {},
      _sortedByConfig = const {};

  /// Creates an index with initial schedules.
  ScheduleIndex.withSchedules(List<Schedule> schedules)
    : _coverageRanges = {},
      _schedulesByConfig = {},
      _sortedByConfig = {} {
    addSchedules(schedules);
  }

  /// Adds schedules to the index and updates coverage ranges.
  void addSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) return;

    // Group schedules by config name
    final Map<String, List<Schedule>> schedulesByConfig = {};
    for (final schedule in schedules) {
      schedulesByConfig
          .putIfAbsent(schedule.configName, () => [])
          .add(schedule);
    }

    // Update index for each config
    for (final entry in schedulesByConfig.entries) {
      final configName = entry.key;
      final configSchedules = entry.value;

      // Add to schedules index
      _schedulesByConfig
          .putIfAbsent(configName, () => [])
          .addAll(configSchedules);

      // Maintain sorted cache incrementally
      final List<Schedule> sorted = List<Schedule>.from(
        _schedulesByConfig[configName]!,
      )..sort((a, b) => a.date.compareTo(b.date));
      _sortedByConfig[configName] = sorted;

      // Update coverage ranges
      _updateCoverageRanges(configName, configSchedules);
    }
  }

  /// Removes schedules from the index and updates coverage ranges.
  void removeSchedules(List<Schedule> schedules) {
    if (schedules.isEmpty) return;

    // Group schedules by config name
    final Map<String, List<Schedule>> schedulesByConfig = {};
    for (final schedule in schedules) {
      schedulesByConfig
          .putIfAbsent(schedule.configName, () => [])
          .add(schedule);
    }

    // Remove from index for each config
    for (final entry in schedulesByConfig.entries) {
      final configName = entry.key;
      final schedulesToRemove = entry.value;

      // Remove from schedules index
      final configSchedules = _schedulesByConfig[configName];
      if (configSchedules != null) {
        configSchedules.removeWhere(
          (schedule) => schedulesToRemove.any(
            (toRemove) =>
                schedule.date == toRemove.date &&
                schedule.configName == toRemove.configName,
          ),
        );

        // Maintain sorted cache after removal
        final List<Schedule> sorted = List<Schedule>.from(configSchedules)
          ..sort((a, b) => a.date.compareTo(b.date));
        _sortedByConfig[configName] = sorted;
      }

      // Rebuild coverage ranges for this config
      _rebuildCoverageRanges(configName);
    }
  }

  /// Replaces all schedules for a config and updates coverage ranges.
  void replaceSchedulesForConfig(String configName, List<Schedule> schedules) {
    _schedulesByConfig[configName] = List.from(schedules);
    final List<Schedule> sorted = List<Schedule>.from(schedules)
      ..sort((a, b) => a.date.compareTo(b.date));
    _sortedByConfig[configName] = sorted;
    _updateCoverageRanges(configName, schedules);
  }

  /// Checks if data exists for the given range using optimized algorithms.
  ///
  /// First performs a fast coverage check (O(k)), then falls back to
  /// binary search (O(log n)) if needed for maximum performance.
  bool hasDataForRange(
    String configName,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Quick coverage check - O(k) where k is number of ranges
    if (_hasCoverageForRange(configName, startDate, endDate)) {
      return true;
    }

    // Fallback to binary search - O(log n)
    return _binarySearchRange(configName, startDate, endDate);
  }

  /// Fast coverage check using pre-computed ranges.
  bool _hasCoverageForRange(
    String configName,
    DateTime startDate,
    DateTime endDate,
  ) {
    final ranges = _coverageRanges[configName];
    if (ranges == null || ranges.isEmpty) return false;

    final queryRange = DateRange(start: startDate, end: endDate);

    return ranges.any((range) => _rangesOverlap(range, queryRange));
  }

  /// Binary search for precise range checking.
  bool _binarySearchRange(
    String configName,
    DateTime startDate,
    DateTime endDate,
  ) {
    final schedules = _sortedByConfig[configName];
    if (schedules == null || schedules.isEmpty) {
      // If sorted schedules are missing, this is a logic error.
      throw StateError(
        'Sorted schedules for config "$configName" are missing. '
        'Ensure _sortedByConfig is always populated for binary search.',
      );
    }

    // Already sorted view
    final sortedSchedules = schedules;

    final start = startDate.subtract(const Duration(days: 1));
    final end = endDate.add(const Duration(days: 1));

    // Binary search for first schedule >= start
    final firstIndex = _binarySearchFirst(sortedSchedules, start);
    if (firstIndex == -1) return false;

    // Check if any schedule in range is <= end
    for (int i = firstIndex; i < sortedSchedules.length; i++) {
      final schedule = sortedSchedules[i];
      if (schedule.date.isAfter(end)) break;
      // Inclusive range check: true if schedule.date is between original start and end (inclusive)
      if (!schedule.date.isBefore(startDate) &&
          !schedule.date.isAfter(endDate)) {
        return true;
      }
    }

    return false;
  }

  /// Binary search to find first schedule >= target date.
  int _binarySearchFirst(List<Schedule> schedules, DateTime target) {
    int left = 0;
    int right = schedules.length - 1;
    int result = -1;

    while (left <= right) {
      final mid = (left + right) ~/ 2;
      final schedule = schedules[mid];

      if (schedule.date.isAtSameMomentAs(target) ||
          schedule.date.isAfter(target)) {
        result = mid;
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    return result;
  }

  /// Updates coverage ranges for a config after adding schedules.
  void _updateCoverageRanges(String configName, List<Schedule> schedules) {
    if (schedules.isEmpty) {
      _coverageRanges[configName] = [];
      return;
    }

    // Get all existing schedules for this config
    final allSchedules = _schedulesByConfig[configName] ?? [];

    // Extract unique dates and sort them
    final dates = allSchedules.map((s) => s.date).toSet().toList()..sort();

    // Merge consecutive dates into ranges
    final ranges = _mergeConsecutiveDates(dates);
    _coverageRanges[configName] = ranges;
  }

  /// Rebuilds coverage ranges for a config after removing schedules.
  void _rebuildCoverageRanges(String configName) {
    final schedules = _schedulesByConfig[configName] ?? [];
    _updateCoverageRanges(configName, schedules);
  }

  /// Merges consecutive dates into date ranges.
  List<DateRange> _mergeConsecutiveDates(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final ranges = <DateRange>[];
    DateTime? rangeStart;
    DateTime? rangeEnd;

    for (final date in dates) {
      if (rangeStart == null) {
        rangeStart = date;
        rangeEnd = date;
      } else if (_isConsecutiveDay(rangeEnd!, date)) {
        rangeEnd = date;
      } else {
        ranges.add(DateRange(start: rangeStart, end: rangeEnd));
        rangeStart = date;
        rangeEnd = date;
      }
    }

    if (rangeStart != null) {
      ranges.add(DateRange(start: rangeStart, end: rangeEnd!));
    }

    return ranges;
  }

  /// Checks if two dates are consecutive days.
  bool _isConsecutiveDay(DateTime date1, DateTime date2) {
    final difference = date2.difference(date1).inDays;
    return difference == 1;
  }

  /// Checks if two date ranges overlap.
  bool _rangesOverlap(DateRange range1, DateRange range2) {
    return range1.start.isBefore(range2.end) &&
        range2.start.isBefore(range1.end);
  }

  /// Gets all schedules for a specific config.
  List<Schedule> getSchedulesForConfig(String configName) {
    return _schedulesByConfig[configName] ?? [];
  }

  /// Gets coverage ranges for a specific config.
  List<DateRange> getCoverageRangesForConfig(String configName) {
    return _coverageRanges[configName] ?? [];
  }

  /// Clears all data from the index.
  void clear() {
    _coverageRanges.clear();
    _schedulesByConfig.clear();
  }

  /// Gets debug information about the index.
  Map<String, dynamic> getDebugInfo() {
    return {
      'configs': _schedulesByConfig.keys.toList(),
      'coverageRanges': _coverageRanges.map(
        (key, value) =>
            MapEntry(key, value.map((r) => '${r.start} - ${r.end}').toList()),
      ),
      'scheduleCounts': _schedulesByConfig.map(
        (key, value) => MapEntry(key, value.length),
      ),
    };
  }
}
