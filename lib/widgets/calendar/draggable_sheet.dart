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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  double _currentHeight = 0.3;
  double _minHeight = 0.3;
  final double _maxHeight = 0.8;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: _currentHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _snapToHeight(double targetHeight) {
    setState(() {
      _currentHeight = targetHeight;
    });
    _heightAnimation = Tween<double>(
      begin: _heightAnimation.value,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final calendarFormat = widget.scheduleProvider.calendarFormat;

    // Calculate calendar height based on format
    double calendarHeight;
    switch (calendarFormat) {
      case CalendarFormat.month:
        calendarHeight = screenSize.height * 0.5; // Month view is more compact
        break;
      case CalendarFormat.week:
        calendarHeight = screenSize.height * 0.3; // Week view is very compact
        break;
      case CalendarFormat.twoWeeks:
        calendarHeight = screenSize.height * 0.4; // 2-week view is medium
        break;
    }

    final availableHeight = screenSize.height - calendarHeight;
    final minSheetHeight = availableHeight / screenSize.height;

    // Update current height when calendar format has changed
    _minHeight = minSheetHeight;

    // If current height is no longer valid, adjust it
    if (_currentHeight < minSheetHeight || _currentHeight > 0.8) {
      // Set to minimum height or an appropriate height
      final targetHeight = _currentHeight < minSheetHeight
          ? minSheetHeight
          : minSheetHeight + 0.1;
      _currentHeight = targetHeight;
      _heightAnimation = Tween<double>(
        begin: _heightAnimation.value,
        end: _currentHeight,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
    } else {
      // Update animation even if height is valid
      // to ensure it matches the current height
      if ((_heightAnimation.value - _currentHeight).abs() > 0.01) {
        _heightAnimation = Tween<double>(
          begin: _heightAnimation.value,
          end: _currentHeight,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ));
        _animationController.forward(from: 0);
      }
    }

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
          child: GestureDetector(
            onPanUpdate: (details) {
              final currentHeight = screenSize.height * _currentHeight;
              final newHeight = currentHeight - details.delta.dy;
              final newHeightPercent = newHeight / screenSize.height;

              if (newHeightPercent >= _minHeight &&
                  newHeightPercent <= _maxHeight) {
                setState(() {
                  _currentHeight = newHeightPercent;
                  // Update animation directly for immediate response
                  _heightAnimation = Tween<double>(
                    begin: _heightAnimation.value,
                    end: _currentHeight,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.linear,
                  ));
                  _animationController.value = 1.0;
                });
              }
            },
            onPanEnd: (details) {
              // No snap - keep current position
              // Optional: Animated transition to current position
              _heightAnimation = Tween<double>(
                begin: _heightAnimation.value,
                end: _currentHeight,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ));
              _animationController.forward(from: 0);
            },
            child: AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                final height = screenSize.height * _heightAnimation.value;
                return Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with accent color
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
                            // Drag handle
                            Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 8),
                              width: double.infinity,
                              height: 30,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            // Services section as header
                            ServicesSection(
                                selectedDay:
                                    widget.scheduleProvider.selectedDay),
                          ],
                        ),
                      ),
                      // Schedule list
                      Expanded(
                        child: ScheduleList(
                          schedules: widget.scheduleProvider.schedules,
                          dutyGroups: widget.scheduleProvider.dutyGroups,
                          selectedDutyGroup:
                              widget.scheduleProvider.selectedDutyGroup,
                          onDutyGroupSelected: (group) {
                            widget.scheduleProvider.setSelectedDutyGroup(group);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCalendar(ScheduleProvider scheduleProvider) {
    final calendar = TableCalendar(
      firstDay: CalendarConfig.firstDay,
      lastDay: CalendarConfig.lastDay,
      focusedDay: scheduleProvider.focusedDay ?? DateTime.now(),
      calendarFormat: scheduleProvider.calendarFormat,
      startingDayOfWeek: CalendarConfig.startingDayOfWeek,
      selectedDayPredicate: (day) {
        return isSameDay(scheduleProvider.selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        scheduleProvider.setSelectedDay(selectedDay);
        scheduleProvider.setFocusedDay(focusedDay);
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
