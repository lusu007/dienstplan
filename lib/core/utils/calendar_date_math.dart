/// Pure calendar arithmetic using UTC date components only. Not shortened by
/// local DST when spanning start/end that are local midnights.
DateTime utcCalendarDateOnly(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day);

/// Difference in whole calendar days from [start] to [end] (inclusive end as
/// same count as looping `i` from `0` through this value with
/// `utcCalendarDateOnly(start).add(Duration(days: i))`).
int utcCalendarDaySpan(DateTime start, DateTime end) {
  final DateTime s = utcCalendarDateOnly(start);
  final DateTime e = utcCalendarDateOnly(end);
  return e.difference(s).inDays;
}

/// Inclusive calendar day count (e.g. Mar 1–Mar 31 → 31).
int utcCalendarInclusiveDayCount(DateTime start, DateTime end) =>
    utcCalendarDaySpan(start, end) + 1;
