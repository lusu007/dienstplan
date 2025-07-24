import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/core/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';

class CalendarNavigationHook {
  final ScheduleController scheduleController;
  final CalendarViewController pageManager;
  final VoidCallback onPageViewKeyChanged;

  CalendarNavigationHook({
    required this.scheduleController,
    required this.pageManager,
    required this.onPageViewKeyChanged,
  });

  void navigateToPreviousPeriod() {
    final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
        scheduleController.focusedDay ?? DateTime.now(),
        scheduleController.calendarFormat);
    scheduleController.setFocusedDay(newFocusedDay);
    _updatePageViewForCalendarNavigation(newFocusedDay);
  }

  void navigateToNextPeriod() {
    final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
        scheduleController.focusedDay ?? DateTime.now(),
        scheduleController.calendarFormat);
    scheduleController.setFocusedDay(newFocusedDay);
    _updatePageViewForCalendarNavigation(newFocusedDay);
  }

  void navigateToToday() {
    final now = DateTime.now();
    scheduleController.setSelectedDay(now);
    scheduleController.setFocusedDay(now);
    pageManager.rebuildDayPagesAroundDay(now);
    onPageViewKeyChanged();
  }

  void _updatePageViewForCalendarNavigation(DateTime newFocusedDay) {
    // When navigating to a new month, we want to show the selected day in the new month
    // But if the selected day doesn't exist in the new month, we show the focused day
    final selectedDay = scheduleController.selectedDay;

    // Determine which day to show in the new month
    DateTime dayToShow;
    if (selectedDay != null) {
      // Try to keep the same day of the month, but validate it exists in the new month
      final lastDayOfNewMonth =
          DateTime(newFocusedDay.year, newFocusedDay.month + 1, 0).day;
      final validDay = selectedDay.day > lastDayOfNewMonth
          ? lastDayOfNewMonth
          : selectedDay.day;
      dayToShow = DateTime(newFocusedDay.year, newFocusedDay.month, validDay);
    } else {
      dayToShow = newFocusedDay;
    }

    // Rebuild the page manager around the day we want to show
    pageManager.rebuildDayPagesAroundDay(dayToShow);
  }
}
