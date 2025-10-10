import 'package:table_calendar/table_calendar.dart';

int getWeekRowsForMonth(
  DateTime focusedDay, {
  StartingDayOfWeek starting = StartingDayOfWeek.monday,
}) {
  final DateTime firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  final DateTime lastOfMonth = DateTime(
    focusedDay.year,
    focusedDay.month + 1,
    0,
  );
  final int startWeekday = firstOfMonth.weekday; // 1..7 (Mon..Sun)
  final int desiredStart = _weekdayFromStarting(starting);
  int leading = (startWeekday - desiredStart) % 7;
  if (leading < 0) leading += 7;
  final int itemCount = leading + lastOfMonth.day; // days incl leading
  final int rows = (itemCount / 7).ceil();
  return rows;
}

int _weekdayFromStarting(StartingDayOfWeek starting) {
  switch (starting) {
    case StartingDayOfWeek.monday:
      return DateTime.monday;
    case StartingDayOfWeek.tuesday:
      return DateTime.tuesday;
    case StartingDayOfWeek.wednesday:
      return DateTime.wednesday;
    case StartingDayOfWeek.thursday:
      return DateTime.thursday;
    case StartingDayOfWeek.friday:
      return DateTime.friday;
    case StartingDayOfWeek.saturday:
      return DateTime.saturday;
    case StartingDayOfWeek.sunday:
      return DateTime.sunday;
  }
}

bool isSixWeekMonth(
  DateTime focusedDay, {
  StartingDayOfWeek starting = StartingDayOfWeek.monday,
}) {
  return getWeekRowsForMonth(focusedDay, starting: starting) >= 6;
}
