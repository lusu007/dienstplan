import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/core/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/header/calendar_header.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/grid/calendar_grid.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/sheet/calendar_sheet.dart';

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

  void _onPageViewKeyChanged() {
    setState(() {
      _pageViewKey = UniqueKey();
    });
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
      _onPageViewKeyChanged();

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

    // Force a complete rebuild of the PageView by changing its key
    _onPageViewKeyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16), // Abstand zur AppBar
        CalendarHeader(
          scheduleController: widget.scheduleController,
          headerKey: _headerKey,
          onPageViewUpdate: _updatePageViewForCalendarNavigation,
        ),
        CalendarGrid(
          scheduleController: widget.scheduleController,
          calendarKey: _calendarKey,
        ),
        const SizedBox(height: 16), // Abstand zwischen Kalender und Sheet
        CalendarSheet(
          pageManager: _pageManager,
          scheduleController: widget.scheduleController,
          pageViewKey: _pageViewKey,
        ),
      ],
    );
  }
}
