import 'package:table_calendar/table_calendar.dart';

class CalendarNavigationHelper {
  static DateTime getPreviousPeriod(
    DateTime currentDate,
    CalendarFormat format,
  ) {
    switch (format) {
      case CalendarFormat.month:
        // For month view, show the previous month but keep the same selected date
        // We need to find the first day of the previous month to set as focusedDay
        final previousMonth = currentDate.month - 1;
        final previousYear = currentDate.year;

        // Handle year transition
        final actualYear = previousMonth <= 0 ? previousYear - 1 : previousYear;
        final actualMonth = previousMonth <= 0
            ? 12 + previousMonth
            : previousMonth;

        // Return the first day of the previous month as focusedDay
        return DateTime(actualYear, actualMonth, 1);
      case CalendarFormat.twoWeeks:
        // For two weeks view, show 2 weeks earlier but keep the same selected date
        return currentDate.subtract(const Duration(days: 14));
      case CalendarFormat.week:
        // For week view, show 1 week earlier but keep the same selected date
        return currentDate.subtract(const Duration(days: 7));
    }
  }

  static DateTime getNextPeriod(DateTime currentDate, CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        // For month view, show the next month but keep the same selected date
        // We need to find the first day of the next month to set as focusedDay
        final nextMonth = currentDate.month + 1;
        final nextYear = currentDate.year;

        // Handle year transition
        final actualYear = nextMonth > 12 ? nextYear + 1 : nextYear;
        final actualMonth = nextMonth > 12 ? nextMonth - 12 : nextMonth;

        // Return the first day of the next month as focusedDay
        return DateTime(actualYear, actualMonth, 1);
      case CalendarFormat.twoWeeks:
        // For two weeks view, show 2 weeks later but keep the same selected date
        return currentDate.add(const Duration(days: 14));
      case CalendarFormat.week:
        // For week view, show 1 week later but keep the same selected date
        return currentDate.add(const Duration(days: 7));
    }
  }
}
