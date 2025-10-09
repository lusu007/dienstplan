import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

/// Optimized calendar day card with selective provider watching
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
    // Selective provider watching - only watch specific parts
    final selectedDay = ref.watch(
      scheduleCoordinatorProvider.select((state) => state.value?.selectedDay),
    );

    final partnerAccentColor = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerAccentColorValue,
      ),
    );

    final myAccentColor = ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.myAccentColorValue,
      ),
    );

    final holidayAccentColor = ref.watch(
      settingsProvider.select((s) => s.value?.holidayAccentColorValue),
    );

    // Watch school holidays state
    final holidaysAsyncValue = ref.watch(schoolHolidaysProvider);
    final holidaysState = holidaysAsyncValue.whenData((data) => data).value;

    final hasSchoolHoliday =
        holidaysState?.isEnabled == true &&
        holidaysState?.hasHolidayOnDate(day) == true;
    final holidays = hasSchoolHoliday
        ? holidaysState?.getHolidaysForDate(day) ?? []
        : [];
    final schoolHolidayName = holidays.isNotEmpty ? holidays.first.name : null;

    final isSelected = _isDaySelected(selectedDay);

    return RepaintBoundary(
      child: AnimatedCalendarDay(
        day: day,
        dutyAbbreviation: dutyAbbreviation ?? '',
        partnerAccentColorValue: partnerAccentColor,
        myAccentColorValue: myAccentColor,
        holidayAccentColorValue: holidayAccentColor,
        dayType: dayType,
        width: width,
        height: height,
        isSelected: isSelected,
        hasSchoolHoliday: hasSchoolHoliday,
        schoolHolidayName: schoolHolidayName,
        onTap: () => _handleDayTap(ref),
      ),
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
