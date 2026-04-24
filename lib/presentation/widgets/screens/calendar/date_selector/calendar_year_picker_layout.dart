// Pure layout math for the calendar year-grid and month pager (min-year-aligned 12-year blocks).
// Blocks are 12-year ranges aligned to [minYear] (not to calendar year 0).

int calendarYearBlockStartForYear({
  required int minYear,
  required int maxYear,
  required int year,
}) {
  final int yearOffsetFromMin = (year - minYear)
      .clamp(0, maxYear - minYear)
      .toInt();
  final int blockOffset = (yearOffsetFromMin ~/ 12) * 12;
  return minYear + blockOffset;
}

int calendarYearGridPageCount({required int minYear, required int maxYear}) {
  return ((maxYear - minYear + 1) / 12).ceil();
}

int calendarYearPickerPageIndex({
  required int minYear,
  required int maxYear,
  required int year,
}) {
  final int yi = (year - minYear).clamp(0, maxYear - minYear).toInt();
  return (yi / 12).floor();
}

int calendarMonthPickerPageIndex({
  required int minYear,
  required int maxYear,
  required int year,
}) {
  return (year - minYear).clamp(0, maxYear - minYear).toInt();
}
