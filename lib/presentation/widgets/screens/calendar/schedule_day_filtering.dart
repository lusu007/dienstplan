import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';

/// Reduces the coordinator schedule list to a single [day] in local calendar
/// time (Y-M-D, UTC-normalized) so [DutyScheduleList] can run its grouping
/// logic. Matches the dialog behaviour.
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

/// If the coordinator has no rows for the active config yet, request the day
/// once (same side-effect as [SchedulesDialog]). Use only from build, via
/// post-frame, so it does not run every frame when empty.
void schedulePostFrameEnsureDayIfEmpty({
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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      ref.read(scheduleCoordinatorProvider.notifier).setSelectedDay(day);
    }
  });
}
