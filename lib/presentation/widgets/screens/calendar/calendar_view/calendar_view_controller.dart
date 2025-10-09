import 'package:flutter/material.dart';

class CalendarViewController {
  final PageController pageController;
  final List<DateTime> dayPages = [];
  int currentPageIndex = 0;
  DateTime? lastSelectedDay;

  // Dynamic loading configuration
  static const int _initialRangeDays = 30;
  static const int _expansionThreshold =
      5; // Load more when within 5 pages of edge
  static const int _expansionSize = 30; // Add 30 days in each direction
  static const int _maxTotalDays =
      180; // Bound total pages to avoid unbounded growth

  CalendarViewController()
    : pageController = PageController(
        initialPage: _initialRangeDays, // Start at the middle page
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
    // Start from _initialRangeDays before to _initialRangeDays after the selected day
    for (int i = -_initialRangeDays; i <= _initialRangeDays; i++) {
      dayPages.add(centerDay.add(Duration(days: i)));
    }

    // Reset to middle page
    currentPageIndex = _initialRangeDays; // Selected day is at middle index

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

  /// Checks if the user is approaching the edge of loaded data and needs expansion
  bool shouldExpandRange(int pageIndex) {
    return pageIndex <= _expansionThreshold ||
        pageIndex >= dayPages.length - _expansionThreshold - 1;
  }

  /// Expands the day pages range in the direction the user is scrolling
  void expandRangeIfNeeded(int pageIndex) {
    if (!shouldExpandRange(pageIndex)) return;

    final bool isNearStart = pageIndex <= _expansionThreshold;
    final bool isNearEnd =
        pageIndex >= dayPages.length - _expansionThreshold - 1;

    if (isNearStart) {
      _expandRangeBackward();
    } else if (isNearEnd) {
      _expandRangeForward();
    }
  }

  /// Expands the range backward (earlier dates)
  void _expandRangeBackward() {
    if (dayPages.isEmpty) return;

    final DateTime firstDay = dayPages.first;
    final List<DateTime> newDays = [];

    // Add _expansionSize days before the current first day
    for (int i = _expansionSize; i >= 1; i--) {
      newDays.add(firstDay.subtract(Duration(days: i)));
    }

    // Insert new days at the beginning
    dayPages.insertAll(0, newDays);

    // Adjust current page index to account for the new days
    currentPageIndex += _expansionSize;

    // Update the PageController position to maintain the same visual page
    if (pageController.hasClients) {
      pageController.jumpToPage(currentPageIndex);
    }

    // Trim from the end if exceeding max size
    _trimIfExceedingMax();
  }

  /// Expands the range forward (later dates)
  void _expandRangeForward() {
    if (dayPages.isEmpty) return;

    final DateTime lastDay = dayPages.last;

    // Add _expansionSize days after the current last day
    for (int i = 1; i <= _expansionSize; i++) {
      dayPages.add(lastDay.add(Duration(days: i)));
    }

    // Trim from the start if exceeding max size
    _trimIfExceedingMax();
  }

  /// Gets the current date range covered by the loaded pages
  DateTimeRange getCurrentDateRange() {
    if (dayPages.isEmpty) {
      final now = DateTime.now();
      return DateTimeRange(start: now, end: now);
    }

    return DateTimeRange(start: dayPages.first, end: dayPages.last);
  }

  void _trimIfExceedingMax() {
    if (dayPages.length <= _maxTotalDays) return;
    final int overflow = dayPages.length - _maxTotalDays;
    // Trim evenly from the side opposite to the user's direction to retain context
    // Here, prefer trimming from the farther side relative to currentPageIndex
    final int trimFromStart = currentPageIndex > dayPages.length / 2
        ? overflow
        : 0;
    final int trimFromEnd = currentPageIndex <= dayPages.length / 2
        ? overflow
        : 0;

    if (trimFromStart > 0) {
      dayPages.removeRange(0, trimFromStart);
      currentPageIndex = (currentPageIndex - trimFromStart).clamp(
        0,
        dayPages.length - 1,
      );
      if (pageController.hasClients) {
        pageController.jumpToPage(currentPageIndex);
      }
    } else if (trimFromEnd > 0) {
      final int newLength = dayPages.length - trimFromEnd;
      dayPages.removeRange(newLength, dayPages.length);
      // currentPageIndex remains valid
    }
  }
}
