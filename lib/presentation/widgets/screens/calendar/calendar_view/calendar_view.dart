import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/utils/calendar_navigation_helper.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({
    super.key,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
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
    final selectedDay =
        ref.read(scheduleNotifierProvider).value?.selectedDay ??
            DateTime.now();
    _pageManager.initializeDayPages(selectedDay);

    // Initialize last known format
    _lastKnownFormat =
        ref.read(scheduleNotifierProvider).value?.calendarFormat;

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
    super.dispose();
  }

  void _onProviderChanged() {
    // Only rebuild if there are actual changes
    final state = ref.read(scheduleNotifierProvider).value;
    final currentFormat = state?.calendarFormat;
    final currentSelectedDay = state?.selectedDay;

    // Check if format changed
    if (_lastKnownFormat != currentFormat) {
      _lastKnownFormat = currentFormat;
      if (mounted) {
        setState(() {});
      }
      return; // Exit early to avoid multiple rebuilds
    }

    // Check if selected day changed
    if (currentSelectedDay != null &&
        (_pageManager.lastSelectedDay == null ||
            !_isSameDay(currentSelectedDay, _pageManager.lastSelectedDay!))) {
      // Update page manager efficiently
      _pageManager.rebuildDayPagesAroundDay(currentSelectedDay);

      // Single rebuild for day change
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _onPageChanged(int pageIndex) {
    _pageManager.onPageChanged(pageIndex, false);

    // Only update focused day when navigating, not selected day
    final newDay = _pageManager.getCurrentDay();
    if (newDay != null) {
      AppLogger.d(
          'CalendarView: _onPageChanged - pageIndex: $pageIndex, newDay: ${newDay.toIso8601String()}');

      // Check if the month has changed
      final currentFocusedDay =
          ref.read(scheduleNotifierProvider).value?.focusedDay;
      final monthChanged = currentFocusedDay == null ||
          currentFocusedDay.year != newDay.year ||
          currentFocusedDay.month != newDay.month;

      if (monthChanged) {
        AppLogger.d(
            'CalendarView: Month changed, updating focused day to ${newDay.toIso8601String()}');
        ref.read(scheduleNotifierProvider.notifier).setFocusedDay(newDay);
      }
    }
  }

  void _updatePageViewForCalendarNavigation(DateTime newFocusedDay) {
    // When navigating to a new month, we want to show the selected day in the new month
    // But if the selected day doesn't exist in the new month, we show the focused day
    final selectedDay =
        ref.read(scheduleNotifierProvider).value?.selectedDay;

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
    // Ensure schedule provider is warmed up
    ref.watch(scheduleNotifierProvider);
    final currentFormat =
        ref.watch(scheduleNotifierProvider).value?.calendarFormat ??
            CalendarFormat.month;

    return Column(
      children: [
        const SizedBox(height: 16), // Abstand zur AppBar
        CalendarViewUiBuilder.buildCalendarHeader(
          context: context,
          headerKey: _headerKey,
          onLeftChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
                ref.read(scheduleNotifierProvider).value?.focusedDay ??
                    DateTime.now(),
                ref
                        .read(scheduleNotifierProvider)
                        .value
                        ?.calendarFormat ??
                    CalendarFormat.month);
            ref
                .read(scheduleNotifierProvider.notifier)
                .setFocusedDay(newFocusedDay);
            // Don't change the selectedDay - keep the current selection

            // Update the PageView to show the current selected day in the new calendar view
            final currentSelectedDay =
                ref.read(scheduleNotifierProvider).value?.selectedDay;
            if (currentSelectedDay != null) {
              _updatePageViewForCalendarNavigation(newFocusedDay);
            }
          },
          onRightChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
                ref.read(scheduleNotifierProvider).value?.focusedDay ??
                    DateTime.now(),
                ref
                        .read(scheduleNotifierProvider)
                        .value
                        ?.calendarFormat ??
                    CalendarFormat.month);
            ref
                .read(scheduleNotifierProvider.notifier)
                .setFocusedDay(newFocusedDay);
            // Don't change the selectedDay - keep the current selection

            // Update the PageView to show the current selected day in the new calendar view
            final currentSelectedDay =
                ref.read(scheduleNotifierProvider).value?.selectedDay;
            if (currentSelectedDay != null) {
              _updatePageViewForCalendarNavigation(newFocusedDay);
            }
          },
          onDateSelected: (selectedDate) {
            // Only change the focused day, keep the selected day unchanged
            // This allows users to navigate to different months while keeping their original selection
            ref
                .read(scheduleNotifierProvider.notifier)
                .setFocusedDay(selectedDate);
            // Don't change selectedDay - preserve the user's original selection
          },
          onTodayButtonPressed: () async {
            // Handle Today button press using the new goToToday method
            await ref.read(scheduleNotifierProvider.notifier).goToToday();

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
            calendarKey: _calendarKey,
            onFormatChanged: (format) {},
            onPageChanged: (focusedDay) {},
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
                ),
                // Filter status text (always visible, never animated)
                CalendarViewUiBuilder.buildFilterStatusText(
                  context: context,
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
      shouldAnimate: false,
    );
  }
}

class _ServicesSectionWrapper extends StatefulWidget {
  final CalendarViewController pageManager;

  const _ServicesSectionWrapper({
    required this.pageManager,
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
    return Consumer(builder: (context, ref, _) {
      final selectedDay =
          ref.watch(scheduleNotifierProvider).value?.selectedDay;
      return CalendarViewUiBuilder.buildServicesSection(
        selectedDay: selectedDay,
      );
    });
  }
}
