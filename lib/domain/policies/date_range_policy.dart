import 'package:dienstplan/domain/value_objects/date_range.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:flutter/material.dart';

abstract class DateRangePolicy {
  DateRange computeInitialRange(DateTime anchor);
  DateRange computeFocusedRange(DateTime focusedMonth);
  DateRange computeSelectedRange(DateTime selectedDay);
  DateRange computeExpandedRange(
    DateTimeRange currentRange,
    DateTime targetDate,
  );
}

class PlusMinusMonthsPolicy implements DateRangePolicy {
  final int monthsBefore;
  final int monthsAfter;

  const PlusMinusMonthsPolicy({
    this.monthsBefore = kMonthsPrefetchRadius,
    this.monthsAfter = kMonthsPrefetchRadius,
  });

  @override
  DateRange computeInitialRange(DateTime anchor) {
    // Load only current month + 1 month ahead for initial load
    // This allows dynamic loading to be tested when navigating beyond this range
    final DateTime start = DateTime(anchor.year, anchor.month, 1);
    final DateTime end = DateTime(
      anchor.year,
      anchor.month + 2, // Current month + 1 month ahead
      0,
    );
    return DateRange(start: start, end: end);
  }

  @override
  DateRange computeFocusedRange(DateTime focusedMonth) {
    final DateTime start = DateTime(
      focusedMonth.year,
      focusedMonth.month - monthsBefore,
      1,
    );
    final DateTime end = DateTime(
      focusedMonth.year,
      focusedMonth.month + monthsAfter + 1,
      0,
    );
    return DateRange(start: start, end: end);
  }

  @override
  DateRange computeSelectedRange(DateTime selectedDay) {
    final DateTime start = DateTime(
      selectedDay.year,
      selectedDay.month - monthsBefore,
      1,
    );
    final DateTime end = DateTime(
      selectedDay.year,
      selectedDay.month + monthsAfter + 1,
      0,
    );
    return DateRange(start: start, end: end);
  }

  @override
  DateRange computeExpandedRange(
    DateTimeRange currentRange,
    DateTime targetDate,
  ) {
    // Calculate how many months we need to expand in each direction
    final DateTime currentStart = currentRange.start;
    final DateTime currentEnd = currentRange.end;

    // Determine if we need to expand backward or forward
    final bool needsBackwardExpansion = targetDate.isBefore(currentStart);
    final bool needsForwardExpansion = targetDate.isAfter(currentEnd);

    DateTime newStart = currentStart;
    DateTime newEnd = currentEnd;

    if (needsBackwardExpansion) {
      // Expand backward by monthsBefore months from the target date
      newStart = DateTime(targetDate.year, targetDate.month - monthsBefore, 1);
    }

    if (needsForwardExpansion) {
      // Expand forward by monthsAfter months from the target date
      newEnd = DateTime(targetDate.year, targetDate.month + monthsAfter + 1, 0);
    }

    return DateRange(start: newStart, end: newEnd);
  }
}
