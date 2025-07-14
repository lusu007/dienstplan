import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/calendar/animated_calendar_day_builder.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime day;
  final ScheduleController scheduleController;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final VoidCallback? onDaySelected;
  final String? dutyAbbreviation;

  const CalendarDayWidget({
    super.key,
    required this.day,
    required this.scheduleController,
    required this.dayType,
    this.width,
    this.height,
    this.onDaySelected,
    this.dutyAbbreviation,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = _isDaySelected();

    return AnimatedCalendarDayBuilder(
      day: day,
      dutyAbbreviation: dutyAbbreviation ?? '',
      dayType: dayType,
      width: width,
      height: height,
      isSelected: isSelected,
      onTap: _handleDayTap,
    );
  }

  bool _isDaySelected() {
    final selectedDay = scheduleController.selectedDay;
    if (selectedDay == null) return false;

    return day.year == selectedDay.year &&
        day.month == selectedDay.month &&
        day.day == selectedDay.day;
  }

  bool _isToday() {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  void _handleDayTap() {
    // Trigger day selection
    scheduleController.setSelectedDay(day);
    scheduleController.setFocusedDay(day);

    // Call the additional callback for animation
    onDaySelected?.call();
  }
}
