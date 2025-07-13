import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/widgets/layout/schedule_list.dart';
import 'package:dienstplan/widgets/calendar/calendar_builders.dart';
import 'package:dienstplan/widgets/calendar/calendar_config.dart';
import 'package:dienstplan/widgets/calendar/services_section.dart';
import 'package:dienstplan/widgets/calendar/custom_calendar_header.dart';

class DraggableSheet extends StatefulWidget {
  final ScheduleProvider scheduleProvider;

  const DraggableSheet({
    super.key,
    required this.scheduleProvider,
  });

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  PageController? _pageController;
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();

  // Track current page index for day navigation
  int _currentPageIndex = 0;
  final List<DateTime> _dayPages = [];
  DateTime? _lastSelectedDay;
  bool _shouldAnimateScheduleList = false;

  @override
  void initState() {
    super.initState();

    // Initialize day pages around current selected day first
    _initializeDayPages();

    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: 1.0,
    );

    // Listen to provider changes to sync calendar
    widget.scheduleProvider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    widget.scheduleProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    final selectedDay = widget.scheduleProvider.selectedDay;

    // Check if the selected day has changed significantly (more than 5 days difference)
    if (selectedDay != null && _lastSelectedDay != null) {
      final daysDifference =
          selectedDay.difference(_lastSelectedDay!).inDays.abs();

      if (daysDifference > 5) {
        // Rebuild the day pages around the new selected day
        _rebuildDayPagesAroundDay(selectedDay);
      }
    }

    _lastSelectedDay = selectedDay;
  }

  void _initializeDayPages() {
    final selectedDay = widget.scheduleProvider.selectedDay ?? DateTime.now();
    _lastSelectedDay = selectedDay;
    _rebuildDayPagesAroundDay(selectedDay);
  }

  void _rebuildDayPagesAroundDay(DateTime centerDay) {
    _dayPages.clear();

    // Create a larger range of days to prevent running out of pages
    // Start from 30 days before to 30 days after the selected day
    for (int i = -30; i <= 30; i++) {
      _dayPages.add(centerDay.add(Duration(days: i)));
    }

    _currentPageIndex = 30; // Selected day is at index 30 (middle)

    // Update the PageController if it has clients
    // Only jump immediately if not animating (for provider changes)
    if (_pageController?.hasClients == true && !_shouldAnimateScheduleList) {
      _pageController!.jumpToPage(_currentPageIndex);
    }
  }

  void _onPageChanged(int pageIndex) {
    if (pageIndex != _currentPageIndex) {
      setState(() {
        _currentPageIndex = pageIndex;
        // Don't animate when scrolling - only when calendar selection
        _shouldAnimateScheduleList = false;
      });

      // Update the selected day in the provider
      final newSelectedDay = _dayPages[pageIndex];
      widget.scheduleProvider.setSelectedDay(newSelectedDay);
      widget.scheduleProvider.setFocusedDay(newSelectedDay);
    }
  }

  void _triggerAnimation() {
    // Set animation flag
    setState(() {
      _shouldAnimateScheduleList = true;
    });

    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _shouldAnimateScheduleList = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16), // Abstand zur AppBar
        CustomCalendarHeader(
          key: _headerKey,
          focusedDay: widget.scheduleProvider.focusedDay ?? DateTime.now(),
          onLeftChevronTap: () {
            final newFocusedDay = _getPreviousPeriod(
                widget.scheduleProvider.focusedDay ?? DateTime.now(),
                widget.scheduleProvider.calendarFormat);
            widget.scheduleProvider.setFocusedDay(newFocusedDay);
          },
          onRightChevronTap: () {
            final newFocusedDay = _getNextPeriod(
                widget.scheduleProvider.focusedDay ?? DateTime.now(),
                widget.scheduleProvider.calendarFormat);
            widget.scheduleProvider.setFocusedDay(newFocusedDay);
          },
          locale: const Locale('de', 'DE'),
          onDateSelected: (selectedDate) {
            widget.scheduleProvider.setFocusedDay(selectedDate);
            widget.scheduleProvider.setSelectedDay(selectedDate);
          },
        ),
        TableCalendar(
          key: _calendarKey,
          firstDay: CalendarConfig.firstDay,
          lastDay: CalendarConfig.lastDay,
          focusedDay: widget.scheduleProvider.focusedDay ?? DateTime.now(),
          calendarFormat: widget.scheduleProvider.calendarFormat,
          startingDayOfWeek: CalendarConfig.startingDayOfWeek,
          selectedDayPredicate: (day) {
            return isSameDay(widget.scheduleProvider.selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            // This callback is not used since we handle day selection in the calendar builders
            // The calendar builders directly call the provider methods
          },
          onFormatChanged: (format) {
            widget.scheduleProvider.setCalendarFormat(format);
          },
          onPageChanged: (focusedDay) {
            widget.scheduleProvider.setFocusedDay(focusedDay);
          },
          calendarBuilders: CalendarBuildersHelper.createCalendarBuilders(
            widget.scheduleProvider,
            onDaySelected: _triggerAnimation,
          ),
          calendarStyle: CalendarConfig.createCalendarStyle(context),
          headerStyle: CalendarConfig.createHeaderStyle(),
          locale: 'de_DE',
        ),
        const SizedBox(height: 16), // Abstand zwischen Kalender und Sheet
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.02,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ServicesSection(
                      selectedDay: _dayPages.isNotEmpty
                          ? _dayPages[_currentPageIndex]
                          : null),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController!,
                    onPageChanged: _onPageChanged,
                    itemCount: _dayPages.length,
                    physics: const PageScrollPhysics(),
                    itemBuilder: (context, index) {
                      final day = _dayPages[index];
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
    return ScheduleList(
      schedules: widget.scheduleProvider.schedules,
      dutyGroups: widget.scheduleProvider.dutyGroups,
      selectedDutyGroup: widget.scheduleProvider.selectedDutyGroup,
      onDutyGroupSelected: (group) {
        widget.scheduleProvider.setSelectedDutyGroup(group);
      },
      shouldAnimate: _shouldAnimateScheduleList,
    );
  }

  DateTime _getPreviousPeriod(DateTime currentDate, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return DateTime(currentDate.year, currentDate.month - 1, 1);
      case CalendarFormat.twoWeeks:
        return currentDate.subtract(const Duration(days: 14));
      case CalendarFormat.week:
        return currentDate.subtract(const Duration(days: 7));
    }
  }

  DateTime _getNextPeriod(DateTime currentDate, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return DateTime(currentDate.year, currentDate.month + 1, 1);
      case CalendarFormat.twoWeeks:
        return currentDate.add(const Duration(days: 14));
      case CalendarFormat.week:
        return currentDate.add(const Duration(days: 7));
    }
  }
}
