import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/core/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/list/schedule_list.dart';
import 'package:dienstplan/core/utils/logger.dart';

class DayPageView extends StatelessWidget {
  final CalendarViewController pageManager;
  final ScheduleController scheduleController;
  final Key pageViewKey;
  final Function(int)? onPageChanged;

  const DayPageView({
    super.key,
    required this.pageManager,
    required this.scheduleController,
    required this.pageViewKey,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: pageViewKey,
      controller: pageManager.pageController,
      onPageChanged: onPageChanged ?? _defaultOnPageChanged,
      itemCount: pageManager.dayPages.length,
      physics: const PageScrollPhysics(),
      itemBuilder: (context, index) {
        final day = pageManager.dayPages[index];
        return _buildDayContent(day);
      },
    );
  }

  Widget _buildDayContent(DateTime day) {
    return ScheduleList(
      scheduleController: scheduleController,
      shouldAnimate: false,
    );
  }

  void _defaultOnPageChanged(int pageIndex) {
    pageManager.onPageChanged(pageIndex, false);

    // Update the selected day in the controller
    final newSelectedDay = pageManager.getCurrentDay();
    if (newSelectedDay != null) {
      AppLogger.d(
          'DayPageView: _onPageChanged - pageIndex: $pageIndex, newSelectedDay: ${newSelectedDay.toIso8601String()}');

      // Only update if the day actually changed to avoid unnecessary rebuilds
      final currentSelectedDay = scheduleController.selectedDay;
      if (currentSelectedDay == null ||
          currentSelectedDay.year != newSelectedDay.year ||
          currentSelectedDay.month != newSelectedDay.month ||
          currentSelectedDay.day != newSelectedDay.day) {
        AppLogger.d(
            'DayPageView: Day changed from ${currentSelectedDay?.toIso8601String()} to ${newSelectedDay.toIso8601String()}');

        // Check if the month has changed
        final currentFocusedDay = scheduleController.focusedDay;
        final monthChanged = currentFocusedDay == null ||
            currentFocusedDay.year != newSelectedDay.year ||
            currentFocusedDay.month != newSelectedDay.month;

        if (monthChanged) {
          AppLogger.d(
              'DayPageView: Month changed, updating focused day to ${newSelectedDay.toIso8601String()}');
          // Update the focused day to match the new month
          scheduleController.setFocusedDay(newSelectedDay);
        }

        // Update selected day when scrolling in the list
        scheduleController.setSelectedDay(newSelectedDay);
      }
    }
  }
}
