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
  CalendarFormat? _lastCalendarFormat;
  double? _lastCalendarHeight;
  final GlobalKey _calendarKey = GlobalKey();
  double? _monthViewMinHeight;

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

  void _updateMonthViewMinHeight(Size screenSize) {
    // Temporär Kalender auf Monatsansicht rendern und Höhe messen
    final RenderBox? calendarRenderBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    final double? currentCalendarHeight = calendarRenderBox?.size.height;
    if (currentCalendarHeight == null) return;
    const double spacingPercent = 0.08;
    final double spacing = screenSize.height * spacingPercent;
    final double availableHeight =
        screenSize.height - currentCalendarHeight - spacing;
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
    // Monatshöhe ggf. aktualisieren
    if (calendarFormat == CalendarFormat.month) {
      _updateMonthViewMinHeight(screenSize);
    }
    // Fallback falls noch nicht gesetzt
    final double minHeight = _monthViewMinHeight ?? 0.1;
    _minHeight = minHeight;
    const double spacingPercent = 0.08;
    final double spacing = screenSize.height * spacingPercent;
    final double availableHeight =
        screenSize.height - currentCalendarHeight - spacing;
    final double newAutoHeight = availableHeight / screenSize.height;
    bool needsAdjustment = false;
    double targetHeight = _currentHeight;
    if (_lastCalendarFormat != calendarFormat ||
        _lastCalendarHeight == null ||
        (currentCalendarHeight - _lastCalendarHeight!).abs() > 1.0) {
      // Automatische Anpassung bei Formatwechsel oder signifikanter Höhenänderung
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
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
    }
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
          child: GestureDetector(
            onPanUpdate: (details) {
              final currentHeight = screenSize.height * _currentHeight;
              final newHeight = currentHeight - details.delta.dy;
              final newHeightPercent = newHeight / screenSize.height;
              if (newHeightPercent >= _minHeight &&
                  newHeightPercent <= _maxHeight) {
                setState(() {
                  _currentHeight = newHeightPercent;
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
                            ServicesSection(
                                selectedDay:
                                    widget.scheduleProvider.selectedDay),
                          ],
                        ),
                      ),
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
