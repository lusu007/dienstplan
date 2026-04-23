import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/schedule_day_filtering.dart';

/// In-layout day list: same data as [SchedulesDialog], glass look with
/// compact typography to match the split calendar.
class DaySchedulesListPanel extends ConsumerWidget {
  const DaySchedulesListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final DateTime day = state?.selectedDay ?? DateTime.now();
    final forDay = filterSchedulesForSingleDay(state?.schedules, day);
    final bool hasForDay = forDay.isNotEmpty;
    final bool isLoadingSelectedDay = (state?.isLoading ?? false) && !hasForDay;

    schedulePostFrameEnsureDayIfEmpty(
      ref: ref,
      context: context,
      day: day,
      hasSchedulesForDay: hasForDay,
      isLoadingSelectedDay: isLoadingSelectedDay,
      activeConfigName: state?.activeConfigName,
    );

    return ScrollFadeMask(
      topFadeFraction: 0.03,
      bottomFadeFraction: 0.06,
      child: DutyScheduleList(
        schedules: forDay,
        activeConfigName: state?.activeConfigName,
        dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
        dutyTypes: state?.activeConfig?.dutyTypes,
        shouldAnimate: false,
        isLoading: isLoadingSelectedDay,
        selectedDay: day,
        visualStyle: DutyListVisualStyle.glassCompact,
        topPadding: 8,
        bottomPadding: 16,
      ),
    );
  }
}
