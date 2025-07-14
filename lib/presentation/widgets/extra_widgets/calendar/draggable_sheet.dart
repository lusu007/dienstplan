import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/draggable_sheet_animation_mixin.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/draggable_sheet_page_manager.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/draggable_sheet_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/calendar_navigation_helper.dart';

class DraggableSheet extends StatefulWidget {
  final ScheduleController scheduleController;

  DraggableSheet({
    super.key,
    required this.scheduleController,
  }) {
    print('DEBUG DraggableSheet: Constructor called');
  }

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet>
    with DraggableSheetAnimationMixin {
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  late final DraggableSheetPageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = DraggableSheetPageManager();

    // Initialize day pages around current selected day first
    final selectedDay = widget.scheduleController.selectedDay ?? DateTime.now();
    _pageManager.initializeDayPages(selectedDay);

    // Listen to controller changes to sync calendar
    print('DEBUG _DraggableSheetState: Adding listener to scheduleController');
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

  void _onProviderChanged() {
    print('DEBUG _DraggableSheetState: _onProviderChanged called');
    // Always rebuild when controller changes (for format changes, etc.)
    if (mounted) {
      print('DEBUG _DraggableSheetState: Calling setState() to rebuild');
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
        widget.scheduleController.setSelectedDay(newSelectedDay);
        widget.scheduleController.setFocusedDay(newSelectedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG _DraggableSheetState: build() called');
    return Column(
      children: [
        const SizedBox(height: 16), // Abstand zur AppBar
        DraggableSheetUiBuilder.buildCalendarHeader(
          scheduleController: widget.scheduleController,
          headerKey: _headerKey,
          onLeftChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getPreviousPeriod(
                widget.scheduleController.focusedDay ?? DateTime.now(),
                widget.scheduleController.calendarFormat);
            widget.scheduleController.setFocusedDay(newFocusedDay);
          },
          onRightChevronTap: () {
            final newFocusedDay = CalendarNavigationHelper.getNextPeriod(
                widget.scheduleController.focusedDay ?? DateTime.now(),
                widget.scheduleController.calendarFormat);
            widget.scheduleController.setFocusedDay(newFocusedDay);
          },
          onDateSelected: (selectedDate) {
            widget.scheduleController.setFocusedDay(selectedDate);
            widget.scheduleController.setSelectedDay(selectedDate);
          },
        ),
        DraggableSheetUiBuilder.buildTableCalendar(
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
        const SizedBox(height: 16), // Abstand zwischen Kalender und Sheet
        Expanded(
          child: DraggableSheetUiBuilder.buildSheetContainer(
            context: context,
            child: Column(
              children: [
                _ServicesSectionWrapper(
                  pageManager: _pageManager,
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
    return DraggableSheetUiBuilder.buildScheduleList(
      scheduleController: widget.scheduleController,
      shouldAnimate: shouldAnimateScheduleList,
    );
  }
}

class _ServicesSectionWrapper extends StatefulWidget {
  final DraggableSheetPageManager pageManager;

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
    // Listen to page changes to rebuild the services section
    widget.pageManager.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageManager.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    // Rebuild the widget when the page changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableSheetUiBuilder.buildServicesSection(
      selectedDay: widget.pageManager.getCurrentDay(),
    );
  }
}
