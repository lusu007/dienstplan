import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';

class CalendarDayCard extends ConsumerWidget {
  final DateTime day;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;
  final String? dutyAbbreviation;

  const CalendarDayCard({
    super.key,
    required this.day,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
    this.dutyAbbreviation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleCoordinatorProvider).value;
    final isSelected = _isDaySelected(scheduleState?.selectedDay);

    return AnimatedCalendarDay(
      day: day,
      dutyAbbreviation: dutyAbbreviation ?? '',
      partnerAccentColorValue: scheduleState?.partnerAccentColorValue,
      myAccentColorValue: scheduleState?.myAccentColorValue,
      dayType: dayType,
      width: width,
      height: height,
      isSelected: isSelected,
      onTap: () => _handleDayTap(ref),
    );
  }

  bool _isDaySelected(DateTime? selectedDay) {
    if (selectedDay == null) return false;

    return day.year == selectedDay.year &&
        day.month == selectedDay.month &&
        day.day == selectedDay.day;
  }

  Future<void> _handleDayTap(WidgetRef ref) async {
    // Trigger day selection via provider
    await ref.read(scheduleCoordinatorProvider.notifier).setSelectedDay(day);
    ref.read(scheduleCoordinatorProvider.notifier).setFocusedDay(day);
  }
}
