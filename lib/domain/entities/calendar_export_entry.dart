class CalendarExportEntry {
  final String uid;
  final String summary;
  final String? description;
  final DateTime startDate;
  final DateTime endDateExclusive;
  final bool isAllDay;

  const CalendarExportEntry({
    required this.uid,
    required this.summary,
    required this.description,
    required this.startDate,
    required this.endDateExclusive,
    this.isAllDay = true,
  });
}
