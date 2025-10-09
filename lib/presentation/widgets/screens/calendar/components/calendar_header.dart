import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector_header.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_navigation_debouncer.dart';
import 'package:table_calendar/table_calendar.dart';

/// Optimized calendar header with RepaintBoundary
class CalendarHeader extends ConsumerStatefulWidget {
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
  ConsumerState<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends ConsumerState<CalendarHeader> {
  late final ScheduleNavigationDebouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = ScheduleNavigationDebouncer();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CalendarDateSelectorHeader(
        key: widget.headerKey,
        onLeftChevronTap: () => _onLeftChevronTap(ref),
        onRightChevronTap: () => _onRightChevronTap(ref),
        locale: Localizations.localeOf(context),
        onDateSelected: widget.onDateSelected,
        onTodayButtonPressed: widget.onTodayButtonPressed,
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

    _debouncer.debounceNavigation(
      'chevron_left_${newFocusedDay.year}_${newFocusedDay.month}',
      () {
        final yearChanged = currentFocusedDay.year != newFocusedDay.year;
        if (yearChanged) {
          ref
              .read(schoolHolidaysProvider.notifier)
              .loadHolidaysForYear(newFocusedDay.year);
        }
        ref
            .read(scheduleCoordinatorProvider.notifier)
            .setFocusedDay(newFocusedDay);
      },
    );
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

    _debouncer.debounceNavigation(
      'chevron_right_${newFocusedDay.year}_${newFocusedDay.month}',
      () {
        final yearChanged = currentFocusedDay.year != newFocusedDay.year;
        if (yearChanged) {
          ref
              .read(schoolHolidaysProvider.notifier)
              .loadHolidaysForYear(newFocusedDay.year);
        }
        ref
            .read(scheduleCoordinatorProvider.notifier)
            .setFocusedDay(newFocusedDay);
      },
    );
  }
}
