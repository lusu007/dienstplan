import 'package:table_calendar/table_calendar.dart';

class CalendarNavigationHelper {
  static DateTime getPreviousPeriod(
      DateTime currentDate, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return DateTime(currentDate.year, currentDate.month - 1, 1);
      case CalendarFormat.twoWeeks:
        return currentDate.subtract(const Duration(days: 14));
      case CalendarFormat.week:
        return currentDate.subtract(const Duration(days: 7));
    }
  }

  static DateTime getNextPeriod(DateTime currentDate, CalendarFormat format) {
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
