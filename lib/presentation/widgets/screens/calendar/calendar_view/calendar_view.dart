import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';
import 'package:dienstplan/core/utils/logger.dart';

class CalendarView extends StatefulWidget {
  final ScheduleController scheduleController;

  const CalendarView({
    super.key,
    required this.scheduleController,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  late final CalendarViewController _pageManager;
  CalendarFormat? _lastKnownFormat;
  Key _pageViewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _pageManager = CalendarViewController();

    // Initialize day pages around current selected day first
    final selectedDay = widget.scheduleController.selectedDay ?? DateTime.now();
    _pageManager.initializeDayPages(selectedDay);

    // Listen to controller changes to sync calendar
    widget.scheduleController.addListener(_onProviderChanged);

    // Initialize last known format
    _lastKnownFormat = widget.scheduleController.calendarFormat;

    // Ensure synchronization on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onProviderChanged();
      }
    });
  }

  @override
  void dispose() {
    _pageManager.dispose();
    widget.scheduleController.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    // Always rebuild when controller changes (for format changes, etc.)
    if (mounted) {
      setState(() {});
    }

    final selectedDay = widget.scheduleController.selectedDay;
    if (selectedDay != null) {
      // Always rebuild the page manager around the selected day to ensure synchronization
      _pageManager.rebuildDayPagesAroundDay(selectedDay);

      // Force a complete rebuild of the PageView by changing its key
      setState(() {
        _pageViewKey = UniqueKey();
      });

      // Force the PageController to jump to the correct page immediately and after a delay
      // This ensures the PageView is properly synchronized
      if (_pageManager.pageController.hasClients) {
        _pageManager.pageController.jumpToPage(_pageManager.currentPageIndex);
      }

      // Additional synchronization after a short delay to handle any timing issues
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted && _pageManager.pageController.hasClients) {
          _pageManager.pageController.jumpToPage(_pageManager.currentPageIndex);
        }
      });
    }

    // Force a rebuild of the calendar to ensure duty chips are updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Force another rebuild after a delay to ensure all updates are processed
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onPageChanged(int pageIndex) {
    _pageManager.onPageChanged(pageIndex, false);

    // Only update focused day when navigating, not selected day
    final newDay = _pageManager.getCurrentDay();
    if (newDay != null) {
      AppLogger.d(
          'CalendarView: _onPageChanged - pageIndex: $pageIndex, newDay: ${newDay.toIso8601String()}');

      // Check if the month has changed
      final currentFocusedDay = widget.scheduleController.focusedDay;
      final monthChanged = currentFocusedDay == null ||
          currentFocusedDay.year != newDay.year ||
          currentFocusedDay.month != newDay.month;

      if (monthChanged) {
        AppLogger.d(
            'CalendarView: Month changed, updating focused day to ${newDay.toIso8601String()}');
        widget.scheduleController.setFocusedDay(newDay);
      }
    }
  }

  void _updatePageViewForCalendarNavigation(DateTime newFocusedDay) {
    // When navigating to a new month, we want to show the selected day in the new month
    // But if the selected day doesn't exist in the new month, we show the focused day
    final selectedDay = widget.scheduleController.selectedDay;

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
    _pageManager.rebuildDayPagesAroundDay(dayToShow);

    // The rebuildDayPagesAroundDay method will automatically jump to the correct page
    // and update the currentPageIndex to 30 (the middle page)
  }

  @override
  Widget build(BuildContext context) {
    final currentFormat = widget.scheduleController.calendarFormat;

    // Check if format changed and force rebuild if needed
    if (_lastKnownFormat != null && _lastKnownFormat != currentFormat) {
      // Force rebuild by updating the key
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    _lastKnownFormat = currentFormat;

    return Column(
      children: [
        const SizedBox(height: 16), // Abstand zur AppBar
        CalendarViewUiBuilder.buildCalendarHeader(
          context: context,
          scheduleController: widget.scheduleController,
          headerKey: _headerKey,
          onLeftChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
                widget.scheduleController.focusedDay ?? DateTime.now(),
                widget.scheduleController.calendarFormat);
            widget.scheduleController.setFocusedDay(newFocusedDay);
            // Don't change the selectedDay - keep the current selection

            // Update the PageView to show the current selected day in the new calendar view
            final currentSelectedDay = widget.scheduleController.selectedDay;
            if (currentSelectedDay != null) {
              _updatePageViewForCalendarNavigation(newFocusedDay);
            }
          },
          onRightChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
                widget.scheduleController.focusedDay ?? DateTime.now(),
                widget.scheduleController.calendarFormat);
            widget.scheduleController.setFocusedDay(newFocusedDay);
            // Don't change the selectedDay - keep the current selection

            // Update the PageView to show the current selected day in the new calendar view
            final currentSelectedDay = widget.scheduleController.selectedDay;
            if (currentSelectedDay != null) {
              _updatePageViewForCalendarNavigation(newFocusedDay);
            }
          },
          onDateSelected: (selectedDate) {
            // Only change the focused day, keep the selected day unchanged
            // This allows users to navigate to different months while keeping their original selection
            widget.scheduleController.setFocusedDay(selectedDate);
            // Don't change selectedDay - preserve the user's original selection
          },
          onTodayButtonPressed: () async {
            // Handle Today button press using the new goToToday method
            await widget.scheduleController.goToToday();

            // Force the PageView to rebuild around the new "today" day
            _pageManager.rebuildDayPagesAroundDay(DateTime.now());

            // Force a complete rebuild of the PageView by changing its key
            setState(() {
              _pageViewKey = UniqueKey();
            });
          },
        ),
        // Create a unique key for the table calendar that changes when format changes
        KeyedSubtree(
          key: ValueKey(
              'draggable_sheet_calendar_${currentFormat}_${DateTime.now().millisecondsSinceEpoch}'),
          child: CalendarViewUiBuilder.buildTableCalendar(
            context: context,
            scheduleController: widget.scheduleController,
            calendarKey: _calendarKey,
            onFormatChanged: (format) async {
              await widget.scheduleController.setCalendarFormat(format);
            },
            onPageChanged: (focusedDay) {
              widget.scheduleController.setFocusedDay(focusedDay);
            },
            onDaySelected: () {},
          ),
        ),
        const SizedBox(height: 16), // Abstand zwischen Kalender und Sheet
        Expanded(
          child: CalendarViewUiBuilder.buildSheetContainer(
            context: context,
            child: Column(
              children: [
                _ServicesSectionWrapper(
                  pageManager: _pageManager,
                  scheduleController: widget.scheduleController,
                ),
                // Filter status text (always visible, never animated)
                CalendarViewUiBuilder.buildFilterStatusText(
                  context: context,
                  scheduleController: widget.scheduleController,
                ),
                Expanded(
                  child: PageView.builder(
                    key: _pageViewKey,
                    controller: _pageManager.pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pageManager.dayPages.length,
                    physics: const PageScrollPhysics(),
                    itemBuilder: (context, index) {
                      final day = _pageManager.dayPages[index];
                      return _buildSheetContent(day);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetContent(DateTime day) {
    return CalendarViewUiBuilder.buildDutyScheduleList(
      context: context,
      scheduleController: widget.scheduleController,
      shouldAnimate: false,
    );
  }
}

class _ServicesSectionWrapper extends StatefulWidget {
  final CalendarViewController pageManager;
  final ScheduleController scheduleController;

  const _ServicesSectionWrapper({
    required this.pageManager,
    required this.scheduleController,
  });

  @override
  State<_ServicesSectionWrapper> createState() =>
      _ServicesSectionWrapperState();
}

class _ServicesSectionWrapperState extends State<_ServicesSectionWrapper> {
  @override
  void initState() {
    super.initState();
    widget.pageManager.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageManager.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.scheduleController,
      builder: (context, child) {
        return CalendarViewUiBuilder.buildServicesSection(
          selectedDay: widget.scheduleController.selectedDay,
        );
      },
    );
  }
}
