import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarConfig {
  static CalendarStyle createCalendarStyle(BuildContext context) {
    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(128),
        shape: BoxShape.circle,
      ),
    );
  }

  static HeaderStyle createHeaderStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      leftChevronVisible: false,
      rightChevronVisible: false,
      titleTextFormatter: null,
      titleTextStyle: TextStyle(fontSize: 0),
    );
  }

  static DateTime get firstDay => DateTime.utc(2018, 1, 1);
  static DateTime get lastDay => DateTime.utc(2100, 12, 31);
  static StartingDayOfWeek get startingDayOfWeek => StartingDayOfWeek.monday;
}
