import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/widgets/layout/schedule_list.dart';
import 'package:dienstplan/widgets/calendar/calendar_builders.dart';
import 'package:dienstplan/widgets/calendar/calendar_config.dart';
import 'package:dienstplan/widgets/calendar/services_section.dart';

class DraggableSheet extends StatefulWidget {
  final ScheduleProvider scheduleProvider;

  const DraggableSheet({
    super.key,
    required this.scheduleProvider,
  });

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet>
    with TickerProviderStateMixin {
  late AnimationController _heightAnimationController;
  late PageController _pageController;
  late Animation<double> _heightAnimation;
  double _currentHeight = 0.3;
  double _collapsedHeight = 0.3;
  final double _expandedHeight = 0.8;
  bool _isDraggingVertically = false;
  CalendarFormat? _lastCalendarFormat;
  double? _lastCalendarHeight;
  final GlobalKey _calendarKey = GlobalKey();
  double? _monthViewMinHeight;

  // Track current page index for day navigation
  int _currentPageIndex = 0;
  final List<DateTime> _dayPages = [];

  @override
  void initState() {
    super.initState();
    _heightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController = PageController(
      initialPage: _currentPageIndex,
      viewportFraction: 1.0,
    );
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: _currentHeight,
    ).animate(CurvedAnimation(
      parent: _heightAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize day pages around current selected day
    _initializeDayPages();

    // Listen to provider changes to sync calendar
    widget.scheduleProvider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _heightAnimationController.dispose();
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

  void _updateMonthViewMinHeight(Size screenSize) {
    // Temporarily render calendar in month view and measure height
    final RenderBox? calendarRenderBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final double? currentCalendarHeight = calendarRenderBox?.size.height;
    if (currentCalendarHeight == null) return;
    const double spacingPercent = 0.08;
    const double cornerRadius = 20.0; // Radius of rounded corners
    final double spacing = screenSize.height * spacingPercent;
    final double availableHeight =
        screenSize.height - currentCalendarHeight - spacing - cornerRadius;
    final double minHeight = availableHeight / screenSize.height;
    _monthViewMinHeight = minHeight;
  }

  void _adjustHeightForCalendarFormat(
      CalendarFormat calendarFormat, Size screenSize) {
    final RenderBox? calendarRenderBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final double? currentCalendarHeight = calendarRenderBox?.size.height;
    if (currentCalendarHeight == null) {
      return;
    }
    // Update month height if needed
    if (calendarFormat == CalendarFormat.month) {
      _updateMonthViewMinHeight(screenSize);
    }
    // Fallback if not set yet
    final double minHeight = _monthViewMinHeight ?? 0.1;
    _collapsedHeight = minHeight;
    const double spacingPercent = 0.08;
    const double cornerRadius = 20.0; // Radius of rounded corners
    final double spacing = screenSize.height * spacingPercent;
    final double availableHeight =
        screenSize.height - currentCalendarHeight - spacing - cornerRadius;
    final double newAutoHeight = availableHeight / screenSize.height;
    bool needsAdjustment = false;
    double targetHeight = _currentHeight;
    if (_lastCalendarFormat != calendarFormat ||
        _lastCalendarHeight == null ||
        (currentCalendarHeight - _lastCalendarHeight!).abs() > 1.0) {
      // Automatic adjustment on format change or significant height change
      targetHeight = newAutoHeight < minHeight ? minHeight : newAutoHeight;
      needsAdjustment = true;
    }
    _lastCalendarFormat = calendarFormat;
    _lastCalendarHeight = currentCalendarHeight;
    if (needsAdjustment) {
      setState(() {
        _currentHeight = targetHeight;
      });
      _heightAnimation = Tween<double>(
        begin: _heightAnimation.value,
        end: targetHeight,
      ).animate(CurvedAnimation(
        parent: _heightAnimationController,
        curve: Curves.easeInOut,
      ));
      _heightAnimationController.forward(from: 0);
    }
  }

  void _snapToNearestPosition() {
    final double midPoint = (_collapsedHeight + _expandedHeight) / 2;
    final double targetHeight =
        _currentHeight < midPoint ? _collapsedHeight : _expandedHeight;

    setState(() {
      _currentHeight = targetHeight;
    });

    _heightAnimation = Tween<double>(
      begin: _heightAnimation.value,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _heightAnimationController,
      curve: Curves.easeInOut,
    ));
    _heightAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final calendarFormat = widget.scheduleProvider.calendarFormat;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adjustHeightForCalendarFormat(calendarFormat, screenSize);
    });
    return Stack(
      children: [
        Column(
          children: [
            _buildTableCalendar(widget.scheduleProvider),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: Listenable.merge([_heightAnimation]),
            builder: (context, child) {
              final height = screenSize.height * _heightAnimation.value;

              return Transform.translate(
                offset: const Offset(0, 0),
                child: GestureDetector(
                  onPanStart: (details) {
                    _isDraggingVertically = true;
                  },
                  onPanUpdate: (details) {
                    if (_isDraggingVertically) {
                      // Only vertical movement for sheet height
                      final currentHeight = screenSize.height * _currentHeight;
                      final newHeight = currentHeight - details.delta.dy;
                      final newHeightPercent = newHeight / screenSize.height;
                      if (newHeightPercent >= _collapsedHeight &&
                          newHeightPercent <= _expandedHeight) {
                        setState(() {
                          _currentHeight = newHeightPercent;
                          _heightAnimation = Tween<double>(
                            begin: _heightAnimation.value,
                            end: _currentHeight,
                          ).animate(CurvedAnimation(
                            parent: _heightAnimationController,
                            curve: Curves.linear,
                          ));
                          _heightAnimationController.value = 1.0;
                        });
                      }
                    }
                  },
                  onPanEnd: (details) {
                    _isDraggingVertically = false;
                    _snapToNearestPosition();
                  },
                  child: Container(
                    height: height,
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
                          child: Column(
                            children: [
                              GestureDetector(
                                onPanStart: (details) {
                                  _isDraggingVertically = true;
                                },
                                onPanUpdate: (details) {
                                  if (_isDraggingVertically) {
                                    // Only vertical movement for sheet height
                                    final currentHeight =
                                        screenSize.height * _currentHeight;
                                    final newHeight =
                                        currentHeight - details.delta.dy;
                                    final newHeightPercent =
                                        newHeight / screenSize.height;
                                    if (newHeightPercent >= _collapsedHeight &&
                                        newHeightPercent <= _expandedHeight) {
                                      setState(() {
                                        _currentHeight = newHeightPercent;
                                        _heightAnimation = Tween<double>(
                                          begin: _heightAnimation.value,
                                          end: _currentHeight,
                                        ).animate(CurvedAnimation(
                                          parent: _heightAnimationController,
                                          curve: Curves.linear,
                                        ));
                                        _heightAnimationController.value = 1.0;
                                      });
                                    }
                                  }
                                },
                                onPanEnd: (details) {
                                  _isDraggingVertically = false;
                                  _snapToNearestPosition();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: double.infinity,
                                  height: 30,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withAlpha((0.7 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ServicesSection(
                                  selectedDay: _dayPages[_currentPageIndex]),
                            ],
                          ),
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
              );
            },
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

  Widget _buildTableCalendar(ScheduleProvider scheduleProvider) {
    final calendar = TableCalendar(
      key: _calendarKey,
      firstDay: CalendarConfig.firstDay,
      lastDay: CalendarConfig.lastDay,
      focusedDay: scheduleProvider.focusedDay ?? DateTime.now(),
      calendarFormat: scheduleProvider.calendarFormat,
      startingDayOfWeek: CalendarConfig.startingDayOfWeek,
      selectedDayPredicate: (day) {
        return isSameDay(scheduleProvider.selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        _navigateToDay(selectedDay);
      },
      onFormatChanged: (format) {
        scheduleProvider.setCalendarFormat(format);
      },
      onPageChanged: (focusedDay) {
        scheduleProvider.setFocusedDay(focusedDay);
      },
      calendarBuilders:
          CalendarBuildersHelper.createCalendarBuilders(scheduleProvider),
      calendarStyle: CalendarConfig.createCalendarStyle(context),
      headerStyle: CalendarConfig.createHeaderStyle(),
      locale: 'de_DE',
    );
    return calendar;
  }
}
