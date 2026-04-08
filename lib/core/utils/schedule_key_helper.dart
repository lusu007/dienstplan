class ScheduleKeyParts {
  final String dateYmd;
  final String configName;
  final String dutyGroupId;
  final String dutyTypeId;
  final String service;

  const ScheduleKeyParts({
    required this.dateYmd,
    required this.configName,
    required this.dutyGroupId,
    required this.dutyTypeId,
    required this.service,
  });
}

class ScheduleKeyHelper {
  static const String _separator = '_';

  /// Calendar y-m-d in [date]'s timezone (local or UTC). Do not use [toUtc] here:
  /// local midnights for range ends (e.g. last day of month) must not shift to the
  /// previous UTC day, or SQL `date_ymd` bounds drop the last calendar day (DST).
  static String formatDateYmd(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String buildScheduleId({
    required DateTime date,
    required String configName,
    required String dutyGroupId,
    required String dutyTypeId,
    required String service,
  }) {
    final String ymd = formatDateYmd(date);
    return [ymd, configName, dutyGroupId, dutyTypeId, service].join(_separator);
  }

  static ScheduleKeyParts parseScheduleId(String id) {
    final List<String> parts = id.split(_separator);
    if (parts.length < 5) {
      throw ArgumentError('Invalid schedule id format: $id');
    }
    return ScheduleKeyParts(
      dateYmd: parts[0],
      configName: parts[1],
      dutyGroupId: parts[2],
      dutyTypeId: parts[3],
      service: parts.sublist(4).join(_separator),
    );
  }
}
