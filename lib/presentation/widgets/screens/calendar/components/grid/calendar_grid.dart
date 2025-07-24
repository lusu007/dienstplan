import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';

class CalendarGrid extends StatelessWidget {
  final ScheduleController scheduleController;
  final GlobalKey calendarKey;
  final Function(CalendarFormat)? onFormatChanged;
  final Function(DateTime)? onPageChanged;
  final VoidCallback? onDaySelected;

  const CalendarGrid({
    super.key,
    required this.scheduleController,
    required this.calendarKey,
    this.onFormatChanged,
    this.onPageChanged,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentFormat = scheduleController.calendarFormat;

    return KeyedSubtree(
      key: ValueKey(
          'calendar_grid_${currentFormat}_${DateTime.now().millisecondsSinceEpoch}'),
      child: CalendarViewUiBuilder.buildTableCalendar(
        context: context,
        scheduleController: scheduleController,
        calendarKey: calendarKey,
        onFormatChanged: onFormatChanged ?? _defaultFormatChanged,
        onPageChanged: onPageChanged ?? _defaultPageChanged,
        onDaySelected: onDaySelected ?? () {},
      ),
    );
  }

  Future<void> _defaultFormatChanged(CalendarFormat format) async {
    await scheduleController.setCalendarFormat(format);
  }

  void _defaultPageChanged(DateTime focusedDay) {
    scheduleController.setFocusedDay(focusedDay);
  }
}
