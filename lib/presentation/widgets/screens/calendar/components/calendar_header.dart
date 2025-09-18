import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector_header.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:table_calendar/table_calendar.dart';

/// Optimized calendar header with RepaintBoundary
class CalendarHeader extends ConsumerWidget {
  final GlobalKey headerKey;
  final Function(DateTime) onDateSelected;
  final VoidCallback? onTodayButtonPressed;

  const CalendarHeader({
    super.key,
    required this.headerKey,
    required this.onDateSelected,
    this.onTodayButtonPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: CalendarDateSelectorHeader(
        key: headerKey,
        onLeftChevronTap: () => _onLeftChevronTap(ref),
        onRightChevronTap: () => _onRightChevronTap(ref),
        locale: Localizations.localeOf(context),
        onDateSelected: onDateSelected,
        onTodayButtonPressed: onTodayButtonPressed,
      ),
    );
  }

  void _onLeftChevronTap(WidgetRef ref) {
    final currentFocusedDay =
        ref.read(scheduleCoordinatorProvider).value?.focusedDay ??
        DateTime.now();
    final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
      currentFocusedDay,
      ref.read(scheduleCoordinatorProvider).value?.calendarFormat ??
          CalendarFormat.month,
    );

    // Check if year has changed and load holidays for the new year
    final yearChanged = currentFocusedDay.year != newFocusedDay.year;
    if (yearChanged) {
      ref
          .read(schoolHolidaysProvider.notifier)
          .loadHolidaysForYear(newFocusedDay.year);
    }

    ref.read(scheduleCoordinatorProvider.notifier).setFocusedDay(newFocusedDay);
  }

  void _onRightChevronTap(WidgetRef ref) {
    final currentFocusedDay =
        ref.read(scheduleCoordinatorProvider).value?.focusedDay ??
        DateTime.now();
    final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
      currentFocusedDay,
      ref.read(scheduleCoordinatorProvider).value?.calendarFormat ??
          CalendarFormat.month,
    );

    // Check if year has changed and load holidays for the new year
    final yearChanged = currentFocusedDay.year != newFocusedDay.year;
    if (yearChanged) {
      ref
          .read(schoolHolidaysProvider.notifier)
          .loadHolidaysForYear(newFocusedDay.year);
    }

    ref.read(scheduleCoordinatorProvider.notifier).setFocusedDay(newFocusedDay);
  }
}
