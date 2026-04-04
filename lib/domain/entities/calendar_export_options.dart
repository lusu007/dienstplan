class CalendarExportOptions {
  final DateTime startDate;
  final DateTime endDate;
  final bool includePartnerSchedule;
  final bool includeHolidays;

  const CalendarExportOptions({
    required this.startDate,
    required this.endDate,
    required this.includePartnerSchedule,
    required this.includeHolidays,
  });

  DateTime get normalizedStartDate =>
      DateTime(startDate.year, startDate.month, startDate.day);

  DateTime get normalizedEndDate =>
      DateTime(endDate.year, endDate.month, endDate.day);
}
