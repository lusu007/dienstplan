import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';

class CalendarHeader extends StatelessWidget {
  final ScheduleController scheduleController;
  final GlobalKey headerKey;
  final VoidCallback? onLeftChevronTap;
  final VoidCallback? onRightChevronTap;
  final Function(DateTime)? onDateSelected;
  final VoidCallback? onTodayButtonPressed;
  final Function(DateTime)? onPageViewUpdate;

  const CalendarHeader({
    super.key,
    required this.scheduleController,
    required this.headerKey,
    this.onLeftChevronTap,
    this.onRightChevronTap,
    this.onDateSelected,
    this.onTodayButtonPressed,
    this.onPageViewUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarViewUiBuilder.buildCalendarHeader(
      context: context,
      scheduleController: scheduleController,
      headerKey: headerKey,
      onLeftChevronTap: onLeftChevronTap ?? _defaultLeftChevronTap,
      onRightChevronTap: onRightChevronTap ?? _defaultRightChevronTap,
      onDateSelected: onDateSelected ?? _defaultDateSelected,
      onTodayButtonPressed: onTodayButtonPressed ?? _defaultTodayButtonPressed,
    );
  }

  void _defaultLeftChevronTap() {
    final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
        scheduleController.focusedDay ?? DateTime.now(),
        scheduleController.calendarFormat);
    scheduleController.setFocusedDay(newFocusedDay);

    // Update PageView if callback is provided
    onPageViewUpdate?.call(newFocusedDay);
  }

  void _defaultRightChevronTap() {
    final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
        scheduleController.focusedDay ?? DateTime.now(),
        scheduleController.calendarFormat);
    scheduleController.setFocusedDay(newFocusedDay);

    // Update PageView if callback is provided
    onPageViewUpdate?.call(newFocusedDay);
  }

  void _defaultDateSelected(DateTime selectedDate) {
    scheduleController.setFocusedDay(selectedDate);
  }

  void _defaultTodayButtonPressed() {
    final now = DateTime.now();
    scheduleController.setSelectedDay(now);
    scheduleController.setFocusedDay(now);

    // Update PageView if callback is provided
    onPageViewUpdate?.call(now);
  }
}
