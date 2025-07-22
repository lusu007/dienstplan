import 'package:flutter/material.dart';

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
    lastSelectedDay = selectedDay;
    rebuildDayPagesAroundDay(selectedDay);

    // Ensure the PageController is at the correct page
    if (pageController.hasClients) {
      pageController.jumpToPage(currentPageIndex);
    }
  }

  void rebuildDayPagesAroundDay(DateTime centerDay) {
    // Clear existing pages
    dayPages.clear();

    // Create a larger range of days to prevent running out of pages
    // Start from 30 days before to 30 days after the selected day
    for (int i = -30; i <= 30; i++) {
      dayPages.add(centerDay.add(Duration(days: i)));
    }

    // Reset to middle page
    currentPageIndex = 30; // Selected day is at index 30 (middle)

    // Update the PageController if it has clients
    if (pageController.hasClients) {
      // Use jumpToPage instead of animateToPage to avoid animation conflicts
      pageController.jumpToPage(currentPageIndex);
    }

    // Also update the lastSelectedDay to prevent unnecessary rebuilds
    lastSelectedDay = centerDay;
  }

  void onPageChanged(int pageIndex, bool shouldAnimate) {
    if (pageIndex != currentPageIndex) {
      // Ensure the page index is within bounds first
      if (pageIndex >= dayPages.length) {
        pageIndex = dayPages.length - 1;
      } else if (pageIndex < 0) {
        pageIndex = 0;
      }

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
}
