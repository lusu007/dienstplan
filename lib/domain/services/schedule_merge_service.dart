import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/value_objects/date_range.dart';

class ScheduleMergeService {
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
      final bool exists =
          merged.any((Schedule s) => _isSameScheduleDayAndGroup(s, newItem));
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
      final bool exists =
          result.any((Schedule e) => _isSameScheduleDayAndGroup(e, s));
      if (!exists) {
        result.add(s);
      }
    }
    return result;
  }

  bool _isSameScheduleDayAndGroup(Schedule a, Schedule b) {
    return a.date.year == b.date.year &&
        a.date.month == b.date.month &&
        a.date.day == b.date.day &&
        a.dutyGroupName == b.dutyGroupName &&
        a.configName == b.configName;
  }
}
