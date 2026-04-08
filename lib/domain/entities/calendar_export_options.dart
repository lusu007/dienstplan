class CalendarExportOptions {
  final DateTime startDate;
  final DateTime endDate;
  final bool includePartnerSchedule;

  /// Prepended to partner event titles in ICS, e.g. "Partner: …" (localized).
  final String partnerSummaryPrefix;

  const CalendarExportOptions({
    required this.startDate,
    required this.endDate,
    required this.includePartnerSchedule,
    required this.partnerSummaryPrefix,
  });

  /// UTC date-only instants from the picker's calendar year/month/day fields.
  /// Aligns with DB range queries (YMD from `DateTime.toUtc()`) and schedule
  /// generation, which builds `DateTime.utc(y, m, d)` from those components.
  DateTime get normalizedStartDate =>
      DateTime.utc(startDate.year, startDate.month, startDate.day);

  DateTime get normalizedEndDate =>
      DateTime.utc(endDate.year, endDate.month, endDate.day);
}
