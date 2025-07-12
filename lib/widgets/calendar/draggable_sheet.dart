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
  late PageController _pageController;
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();

  // Track current page index for day navigation
  int _currentPageIndex = 0;
  final List<DateTime> _dayPages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: 1.0,
    );

    // Initialize day pages around current selected day
    _initializeDayPages();

    // Listen to provider changes to sync calendar
    widget.scheduleProvider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    widget.scheduleProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    // Sync page view with provider changes
    final selectedDay = widget.scheduleProvider.selectedDay;
    if (selectedDay != null) {
      final targetIndex = _dayPages.indexWhere((day) =>
          day.year == selectedDay.year &&
          day.month == selectedDay.month &&
          day.day == selectedDay.day);

      if (targetIndex != -1 && targetIndex != _currentPageIndex) {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _initializeDayPages() {
    final selectedDay = widget.scheduleProvider.selectedDay ?? DateTime.now();
    _dayPages.clear();

    // Add 3 days before, current day, and 3 days after
    for (int i = -3; i <= 3; i++) {
      _dayPages.add(selectedDay.add(Duration(days: i)));
    }

    _currentPageIndex = 3; // Current day is at index 3
  }

  void _updateDayPages() {
    // Check if we need to add more days to the list
    if (_currentPageIndex <= 1) {
      // Add more days at the beginning
      final firstDay = _dayPages.first;
      for (int i = 1; i <= 3; i++) {
        _dayPages.insert(0, firstDay.subtract(Duration(days: i)));
      }
      _currentPageIndex += 3;
    } else if (_currentPageIndex >= _dayPages.length - 2) {
      // Add more days at the end
      final lastDay = _dayPages.last;
      for (int i = 1; i <= 3; i++) {
        _dayPages.add(lastDay.add(Duration(days: i)));
      }
    }
  }

  void _onPageChanged(int pageIndex) {
    if (pageIndex != _currentPageIndex) {
      setState(() {
        _currentPageIndex = pageIndex;
      });

      // Update the selected day in the provider
      final newSelectedDay = _dayPages[pageIndex];
      widget.scheduleProvider.setSelectedDay(newSelectedDay);
      widget.scheduleProvider.setFocusedDay(newSelectedDay);

      // Update day pages if needed
      _updateDayPages();
    }
  }

  void _navigateToDay(DateTime targetDay) {
    final targetIndex = _dayPages.indexWhere((day) =>
        day.year == targetDay.year &&
        day.month == targetDay.month &&
        day.day == targetDay.day);

    if (targetIndex != -1) {
      final pageIndex = targetIndex;
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If day not in current pages, rebuild the list around target day
      _dayPages.clear();
      for (int i = -3; i <= 3; i++) {
        _dayPages.add(targetDay.add(Duration(days: i)));
      }
      _currentPageIndex = 3;
      _pageController.jumpToPage(_currentPageIndex);

      widget.scheduleProvider.setSelectedDay(targetDay);
      widget.scheduleProvider.setFocusedDay(targetDay);
    }
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
            _navigateToDay(selectedDay);
          },
          onFormatChanged: (format) {
            widget.scheduleProvider.setCalendarFormat(format);
          },
          onPageChanged: (focusedDay) {
            widget.scheduleProvider.setFocusedDay(focusedDay);
          },
          calendarBuilders: CalendarBuildersHelper.createCalendarBuilders(
              widget.scheduleProvider),
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
                    controller: _pageController,
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
