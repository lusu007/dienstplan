import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/draggable_sheet.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

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
        ref.read(calendarProvider).value?.selectedDay ?? DateTime.now();
    _pageManager.initializeDayPages(selectedDay);

    // Initialize last known format
    _lastKnownFormat = ref.read(calendarProvider).value?.calendarFormat;

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
    final state = ref.read(calendarProvider).value;
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

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  void _onPageChanged(int pageIndex) {
    _pageManager.onPageChanged(pageIndex, false);

    // Check if we need to expand the range dynamically
    if (_pageManager.shouldExpandRange(pageIndex)) {
      // Expand the range first
      _pageManager.expandRangeIfNeeded(pageIndex);

      // Trigger a rebuild to update the PageView with new pages
      if (mounted) {
        setState(() {});
      }

      // Trigger dynamic loading for the expanded range
      _loadSchedulesForExpandedRange();
    }

    // Only update focused day when navigating, not selected day
    final newDay = _pageManager.getCurrentDay();
    if (newDay != null) {
      AppLogger.d(
        'CalendarView: _onPageChanged - pageIndex: $pageIndex, newDay: ${newDay.toIso8601String()}',
      );

      // Check if the month has changed
      final currentFocusedDay = ref.read(calendarProvider).value?.focusedDay;
      final monthChanged =
          currentFocusedDay == null ||
          currentFocusedDay.year != newDay.year ||
          currentFocusedDay.month != newDay.month;

      if (monthChanged) {
        AppLogger.d(
          'CalendarView: Month changed, updating focused day to ${newDay.toIso8601String()}',
        );
        // Also set selected day to ensure the duty list has a day to show
        ref.read(calendarProvider.notifier).setSelectedDay(newDay);
        ref.read(calendarProvider.notifier).setFocusedDay(newDay);

        // Load school holidays for the new month
        final start = DateTime(newDay.year, newDay.month, 1);
        final end = DateTime(newDay.year, newDay.month + 1, 0);
        ref
            .read(schoolHolidaysProvider.notifier)
            .loadHolidaysForRange(start, end);
      }
    }
  }

  /// Loads schedules for the expanded date range when user scrolls beyond current data
  void _loadSchedulesForExpandedRange() {
    final currentRange = _pageManager.getCurrentDateRange();
    final currentDay = _pageManager.getCurrentDay();
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;

    if (currentDay != null && scheduleState?.activeConfigName != null) {
      // Load schedules for the expanded range in the background
      ref
          .read(scheduleCoordinatorProvider.notifier)
          .loadSchedulesForExpandedRange(
            currentRange: currentRange,
            targetDate: currentDay,
            configName: scheduleState!.activeConfigName!,
          );
    }
  }

  /// Triggers dynamic loading when focused day changes (e.g., via chevron navigation)
  void _triggerDynamicLoadingForFocusedDayChange(DateTime focusedDay) {
    AppLogger.d(
      'CalendarView: _triggerDynamicLoadingForFocusedDayChange called for $focusedDay',
    );

    // Update the page manager to reflect the new focused day
    _pageManager.rebuildDayPagesAroundDay(focusedDay);
    AppLogger.d('CalendarView: Page manager rebuilt around $focusedDay');

    // Trigger a rebuild to update the PageView
    if (mounted) {
      setState(() {});
      AppLogger.d('CalendarView: setState called to update PageView');
    }

    // The schedule coordinator will handle the actual loading
    // since we already extended setFocusedDay to trigger dynamic loading
    AppLogger.d('CalendarView: Dynamic loading trigger completed');
  }

  @override
  Widget build(BuildContext context) {
    // Ensure calendar provider is warmed up
    ref.watch(calendarProvider);

    // Watch for focused day changes to trigger dynamic loading
    ref.listen(scheduleCoordinatorProvider, (previous, next) {
      final previousFocusedDay = previous?.value?.focusedDay;
      final currentFocusedDay = next.value?.focusedDay;

      AppLogger.d(
        'CalendarView: Focused day changed from $previousFocusedDay to $currentFocusedDay',
      );

      if (previousFocusedDay != null &&
          currentFocusedDay != null &&
          !_isSameMonth(previousFocusedDay, currentFocusedDay)) {
        // Focused day changed to a different month, trigger dynamic loading
        AppLogger.d('CalendarView: Month changed, triggering dynamic loading');
        _triggerDynamicLoadingForFocusedDayChange(currentFocusedDay);
      } else {
        AppLogger.d(
          'CalendarView: Same month or no previous focused day, skipping dynamic loading',
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main content with calendar
          Column(
            children: [
              const SizedBox(height: 16), // Abstand zur AppBar
              CalendarHeader(
                headerKey: _headerKey,
                onDateSelected: (selectedDate) {
                  // Only change the focused day, keep the selected day unchanged
                  ref
                      .read(scheduleCoordinatorProvider.notifier)
                      .setFocusedDay(selectedDate);
                },
                onTodayButtonPressed: () async {
                  // Handle Today button press using the new goToToday method
                  await ref
                      .read(scheduleCoordinatorProvider.notifier)
                      .goToToday();

                  // Force the PageView to rebuild around the new "today" day
                  _pageManager.rebuildDayPagesAroundDay(DateTime.now());

                  // Force a complete rebuild of the PageView by changing its key
                  setState(() {
                    _pageViewKey = UniqueKey();
                  });
                },
              ),
              // Calendar section
              Expanded(
                child: CalendarTable(
                  calendarKey: _calendarKey,
                  onFormatChanged: (format) {},
                  onPageChanged: (focusedDay) {},
                  onDaySelected: () {},
                ),
              ),
            ],
          ),
          // Draggable sheet overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DraggableSheet(
              pageManager: _pageManager,
              pageViewKey: _pageViewKey,
              onPageChanged: _onPageChanged,
              buildSheetContent: _buildSheetContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(DateTime day) {
    return CalendarViewUiBuilder.buildDutyScheduleList(
      context: context,
      shouldAnimate: false,
    );
  }
}
