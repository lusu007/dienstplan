import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_animations.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';

class CalendarView extends StatefulWidget {
  final ScheduleController scheduleController;

  const CalendarView({
    super.key,
    required this.scheduleController,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with CalendarViewAnimations {
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  late final CalendarViewController _pageManager;
  CalendarFormat? _lastKnownFormat;

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
      _pageManager.checkAndRebuildPages(selectedDay);
      // Ensure the page manager's current day is synchronized with the controller
      final currentDay = _pageManager.getCurrentDay();
      if (currentDay != null &&
          (currentDay.year != selectedDay.year ||
              currentDay.month != selectedDay.month ||
              currentDay.day != selectedDay.day)) {
        // Find the page index for the selected day and jump to it
        final dayIndex = _pageManager.dayPages.indexWhere((day) =>
            day.year == selectedDay.year &&
            day.month == selectedDay.month &&
            day.day == selectedDay.day);
        if (dayIndex != -1) {
          _pageManager.currentPageIndex = dayIndex;
          if (_pageManager.pageController.hasClients) {
            _pageManager.pageController.jumpToPage(dayIndex);
          }
        }
      }
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
    _pageManager.onPageChanged(pageIndex, shouldAnimateScheduleList);

    // Update the selected day in the controller
    final newSelectedDay = _pageManager.getCurrentDay();
    if (newSelectedDay != null) {
      // Only update if the day actually changed to avoid unnecessary rebuilds
      final currentSelectedDay = widget.scheduleController.selectedDay;
      if (currentSelectedDay == null ||
          currentSelectedDay.year != newSelectedDay.year ||
          currentSelectedDay.month != newSelectedDay.month ||
          currentSelectedDay.day != newSelectedDay.day) {
        // Only update selected day, not focused day
        // The focused day should only be updated by the TableCalendar's onPageChanged
        widget.scheduleController.setSelectedDay(newSelectedDay);
      }
    }
  }

  void _updatePageViewForCalendarNavigation(DateTime newFocusedDay) {
    // When navigating to a new month, we want to show the selected day in the new month
    // But if the selected day doesn't exist in the new month, we show the focused day
    final selectedDay = widget.scheduleController.selectedDay;
    final dayToShow = selectedDay ?? newFocusedDay;

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
            onDaySelected: triggerAnimation,
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
      shouldAnimate: shouldAnimateScheduleList,
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
