import 'package:dienstplan/domain/entities/calendar_export_entry.dart';

class CalendarExportPayload {
  final String calendarName;
  final String fileName;
  final List<CalendarExportEntry> entries;

  const CalendarExportPayload({
    required this.calendarName,
    required this.fileName,
    required this.entries,
  });
}
