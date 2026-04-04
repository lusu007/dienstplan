import 'dart:convert';
import 'dart:io';

import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/calendar_export_payload.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CalendarExportShareResult {
  final String filePath;
  final int entryCount;

  const CalendarExportShareResult({
    required this.filePath,
    required this.entryCount,
  });
}

class CalendarExportService {
  Future<Result<CalendarExportShareResult>> shareCalendarExport({
    required CalendarExportPayload payload,
    required AppLocalizations l10n,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File(path.join(directory.path, payload.fileName));
      final content = _buildIcsContent(payload);

      await file.writeAsString(content, encoding: utf8, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/calendar')],
          subject: l10n.exportCalendarSubject,
          text: l10n.exportCalendarShareText,
        ),
      );

      AppLogger.i(
        'Calendar export shared successfully (filePath=${file.path}, entryCount=${payload.entries.length})',
      );

      return Result.success<CalendarExportShareResult>(
        CalendarExportShareResult(
          filePath: file.path,
          entryCount: payload.entries.length,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export sharing failed (fileName=${payload.fileName}, entryCount=${payload.entries.length})',
        error,
        stackTrace,
      );
      return Result.createFailure<CalendarExportShareResult>(
        StorageFailure(
          technicalMessage:
              'Calendar export sharing failed (fileName=${payload.fileName})',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _buildIcsContent(CalendarExportPayload payload) {
    final buffer = StringBuffer()
      ..write('BEGIN:VCALENDAR\r\n')
      ..write('VERSION:2.0\r\n')
      ..write('PRODID:-//Dienstplan//Calendar Export//EN\r\n')
      ..write('CALSCALE:GREGORIAN\r\n')
      ..write('METHOD:PUBLISH\r\n')
      ..write(_buildTextLine('X-WR-CALNAME', payload.calendarName));

    for (final entry in payload.entries) {
      buffer.write('BEGIN:VEVENT\r\n');
      buffer.write(_buildTextLine('UID', entry.uid));
      buffer.write('DTSTAMP:${_formatUtcDateTime(DateTime.now().toUtc())}\r\n');

      if (entry.isAllDay) {
        buffer.write('DTSTART;VALUE=DATE:${_formatDate(entry.startDate)}\r\n');
        buffer.write(
          'DTEND;VALUE=DATE:${_formatDate(entry.endDateExclusive)}\r\n',
        );
      } else {
        buffer.write(
          'DTSTART:${_formatUtcDateTime(entry.startDate.toUtc())}\r\n',
        );
        buffer.write(
          'DTEND:${_formatUtcDateTime(entry.endDateExclusive.toUtc())}\r\n',
        );
      }

      buffer.write(_buildTextLine('SUMMARY', entry.summary));
      if (entry.description != null && entry.description!.isNotEmpty) {
        buffer.write(_buildTextLine('DESCRIPTION', entry.description!));
      }
      buffer.write('END:VEVENT\r\n');
    }

    buffer.write('END:VCALENDAR\r\n');
    return buffer.toString();
  }

  String _buildTextLine(String key, String value) {
    return '$key:${_escapeText(value)}\r\n';
  }

  String _escapeText(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('\n', r'\n')
        .replaceAll(',', r'\,')
        .replaceAll(';', r'\;');
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  String _formatUtcDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$year$month$day'
        'T$hour$minute$second'
        'Z';
  }
}
