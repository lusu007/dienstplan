import 'package:flutter/material.dart';
import 'package:dienstplan/core/utils/logger.dart';

class CalendarViewController {
  final PageController pageController;
  final List<DateTime> dayPages = [];
  int currentPageIndex = 0;
  DateTime? lastSelectedDay;

  CalendarViewController()
      : pageController = PageController(
          initialPage: 30, // Start at the middle page (index 30)
          viewportFraction: 1.0,
        );

  void dispose() {
    pageController.dispose();
  }

  void initializeDayPages(DateTime selectedDay) {
    AppLogger.d(
        'CalendarViewController: Initializing day pages around ${selectedDay.toIso8601String()}');
    lastSelectedDay = selectedDay;
    rebuildDayPagesAroundDay(selectedDay);

    // Ensure the PageController is at the correct page
    if (pageController.hasClients) {
      pageController.jumpToPage(currentPageIndex);
      AppLogger.d(
          'CalendarViewController: Initialized and jumped to page $currentPageIndex');
    }
  }

  void rebuildDayPagesAroundDay(DateTime centerDay) {
    dayPages.clear();

    // Create a larger range of days to prevent running out of pages
    // Start from 30 days before to 30 days after the selected day
    for (int i = -30; i <= 30; i++) {
      dayPages.add(centerDay.add(Duration(days: i)));
    }

    currentPageIndex = 30; // Selected day is at index 30 (middle)

    // Debug logging to verify the day pages are correct
    AppLogger.d(
        'CalendarViewController: Rebuilt pages around ${centerDay.toIso8601String()}');
    AppLogger.d(
        'CalendarViewController: Index 30 (center): ${dayPages[30].toIso8601String()}');
    AppLogger.d(
        'CalendarViewController: Index 31 (next): ${dayPages[31].toIso8601String()}');
    AppLogger.d(
        'CalendarViewController: Index 29 (prev): ${dayPages[29].toIso8601String()}');

    // Update the PageController if it has clients
    if (pageController.hasClients) {
      // Use jumpToPage instead of animateToPage to avoid animation conflicts
      pageController.jumpToPage(currentPageIndex);
      AppLogger.d('CalendarViewController: Jumped to page $currentPageIndex');
    } else {
      AppLogger.d(
          'CalendarViewController: PageController has no clients, cannot jump');
    }
  }

  void onPageChanged(int pageIndex, bool shouldAnimate) {
    if (pageIndex != currentPageIndex) {
      final oldIndex = currentPageIndex;

      // Ensure the page index is within bounds first
      if (pageIndex >= dayPages.length) {
        pageIndex = dayPages.length - 1;
        AppLogger.w(
            'CalendarViewController: Page index $pageIndex out of bounds, clamping to ${dayPages.length - 1}');
      } else if (pageIndex < 0) {
        pageIndex = 0;
        AppLogger.w(
            'CalendarViewController: Page index $pageIndex out of bounds, clamping to 0');
      }

      currentPageIndex = pageIndex;

      // Debug logging
      if (dayPages.isNotEmpty && pageIndex < dayPages.length) {
        AppLogger.d(
            'CalendarViewController: Page changed from $oldIndex to $pageIndex');
        AppLogger.d(
            'CalendarViewController: Old day: ${dayPages[oldIndex].toIso8601String()}');
        AppLogger.d(
            'CalendarViewController: New day: ${dayPages[pageIndex].toIso8601String()}');
      }

      // Don't animate when scrolling - only when calendar selection
      if (shouldAnimate) {
        // Handle animation state here if needed
      }
    }
  }

  DateTime? getCurrentDay() {
    if (dayPages.isNotEmpty && currentPageIndex < dayPages.length) {
      return dayPages[currentPageIndex];
    }
    return null;
  }

  void checkAndRebuildPages(DateTime? selectedDay) {
    // Check if the selected day has changed significantly (more than 5 days difference)
    if (selectedDay != null && lastSelectedDay != null) {
      final daysDifference =
          selectedDay.difference(lastSelectedDay!).inDays.abs();

      if (daysDifference > 5) {
        // Rebuild the day pages around the new selected day
        rebuildDayPagesAroundDay(selectedDay);
      }
    }

    lastSelectedDay = selectedDay;
  }
}
