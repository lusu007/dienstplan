import 'package:flutter/material.dart';

class CalendarViewPageManager {
  final PageController pageController;
  final List<DateTime> dayPages = [];
  int currentPageIndex = 0;
  DateTime? lastSelectedDay;

  CalendarViewPageManager()
      : pageController = PageController(
          initialPage: 0,
          viewportFraction: 1.0,
        );

  void dispose() {
    pageController.dispose();
  }

  void initializeDayPages(DateTime selectedDay) {
    lastSelectedDay = selectedDay;
    rebuildDayPagesAroundDay(selectedDay);
  }

  void rebuildDayPagesAroundDay(DateTime centerDay) {
    dayPages.clear();

    // Create a larger range of days to prevent running out of pages
    // Start from 30 days before to 30 days after the selected day
    for (int i = -30; i <= 30; i++) {
      dayPages.add(centerDay.add(Duration(days: i)));
    }

    currentPageIndex = 30; // Selected day is at index 30 (middle)

    // Update the PageController if it has clients
    if (pageController.hasClients) {
      pageController.animateToPage(
        currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int pageIndex, bool shouldAnimate) {
    if (pageIndex != currentPageIndex) {
      currentPageIndex = pageIndex;
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
