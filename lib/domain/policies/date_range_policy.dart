import 'package:dienstplan/domain/value_objects/date_range.dart';

abstract class DateRangePolicy {
  DateRange computeInitialRange(DateTime anchor);
  DateRange computeFocusedRange(DateTime focusedMonth);
  DateRange computeSelectedRange(DateTime selectedDay);
}

class PlusMinusMonthsPolicy implements DateRangePolicy {
  final int monthsBefore;
  final int monthsAfter;

  const PlusMinusMonthsPolicy({
    this.monthsBefore = 3,
    this.monthsAfter = 3,
  });

  @override
  DateRange computeInitialRange(DateTime anchor) {
    final DateTime start =
        DateTime(anchor.year, anchor.month - monthsBefore, 1);
    final DateTime end =
        DateTime(anchor.year, anchor.month + monthsAfter + 1, 0);
    return DateRange(start: start, end: end);
  }

  @override
  DateRange computeFocusedRange(DateTime focusedMonth) {
    final DateTime start =
        DateTime(focusedMonth.year, focusedMonth.month - monthsBefore, 1);
    final DateTime end =
        DateTime(focusedMonth.year, focusedMonth.month + monthsAfter + 1, 0);
    return DateRange(start: start, end: end);
  }

  @override
  DateRange computeSelectedRange(DateTime selectedDay) {
    final DateTime start =
        DateTime(selectedDay.year, selectedDay.month - monthsBefore, 1);
    final DateTime end =
        DateTime(selectedDay.year, selectedDay.month + monthsAfter + 1, 0);
    return DateRange(start: start, end: end);
  }
}
