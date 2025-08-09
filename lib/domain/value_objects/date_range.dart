class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool containsDate(DateTime date) {
    final DateTime inclusiveStart = start.subtract(const Duration(days: 1));
    final DateTime inclusiveEnd = end.add(const Duration(days: 1));
    return date.isAfter(inclusiveStart) && date.isBefore(inclusiveEnd);
  }

  static DateRange union(DateRange a, DateRange b) {
    final DateTime start = a.start.isBefore(b.start) ? a.start : b.start;
    final DateTime end = a.end.isAfter(b.end) ? a.end : b.end;
    return DateRange(start: start, end: end);
  }
}
