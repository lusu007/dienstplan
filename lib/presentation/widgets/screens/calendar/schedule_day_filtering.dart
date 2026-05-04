import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';

/// Reduces the coordinator schedule list to a single [day] in local calendar
/// time (Y-M-D, UTC-normalized) so [DutyScheduleList] can run its grouping
/// logic. Matches the schedules sheet behaviour.
List<Schedule> filterSchedulesForSingleDay(
  List<Schedule>? allSchedules,
  DateTime day,
) {
  if (allSchedules == null) {
    return const <Schedule>[];
  }
  final DateTime target = DateTime.utc(day.year, day.month, day.day);
  return allSchedules
      .where((Schedule s) {
        final DateTime scheduleDate = DateTime.utc(
          s.date.year,
          s.date.month,
          s.date.day,
        );
        return scheduleDate.isAtSameMomentAs(target);
      })
      .toList(growable: false);
}

/// Coalesces post-frame [ScheduleCoordinatorNotifier.setSelectedDay] calls when
/// the day list is empty so multiple builds in one frame do not enqueue
/// redundant callbacks.
class EnsureSelectedDayPostFrame {
  bool _callbackScheduled = false;
  DateTime? _pendingDay;

  /// If the coordinator has no rows for the active config yet, request the day
  /// once (same side-effect as the schedules sheet). Call from [State.build];
  /// the actual update runs after the frame.
  void scheduleIfEmpty({
    required WidgetRef ref,
    required BuildContext context,
    required DateTime day,
    required bool hasSchedulesForDay,
    required bool isLoadingSelectedDay,
    required String? activeConfigName,
  }) {
    if (hasSchedulesForDay || isLoadingSelectedDay || activeConfigName == null) {
      return;
    }
    _pendingDay = day;
    if (_callbackScheduled) {
      return;
    }
    _callbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _callbackScheduled = false;
      final DateTime? targetDay = _pendingDay;
      if (targetDay == null || !context.mounted) {
        return;
      }
      ref.read(scheduleCoordinatorProvider.notifier).setSelectedDay(targetDay);
    });
  }
}
