import 'dart:convert';
import 'dart:io';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/calendar_export_payload.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CalendarExportPreparedResult {
  final String filePath;
  final int entryCount;
  final String fileName;

  const CalendarExportPreparedResult({
    required this.filePath,
    required this.entryCount,
    required this.fileName,
  });
}

class CalendarExportService {
  Future<Result<CalendarExportPreparedResult>> writeCalendarExportToTemp(
    CalendarExportPayload payload,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File(path.join(directory.path, payload.fileName));
      final content = _buildIcsContent(payload);
      await file.writeAsString(content, encoding: utf8, flush: true);
      AppLogger.i(
        'Calendar export prepared in temp (entryCount=${payload.entries.length})',
      );
      return Result.success<CalendarExportPreparedResult>(
        CalendarExportPreparedResult(
          filePath: file.path,
          entryCount: payload.entries.length,
          fileName: payload.fileName,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export temp write failed (fileName=${payload.fileName}, entryCount=${payload.entries.length})',
        error,
        stackTrace,
      );
      return Result.createFailure<CalendarExportPreparedResult>(
        StorageFailure(
          technicalMessage:
              'Calendar export temp write failed (fileName=${payload.fileName})',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<void>> sharePreparedCalendarExport({
    required String filePath,
    required int entryCount,
    required AppLocalizations l10n,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'text/calendar')],
          subject: l10n.exportCalendarSubject,
          text: l10n.exportCalendarShareText,
        ),
      );
      AppLogger.i(
        'Calendar export shared successfully (entryCount=$entryCount)',
      );
      return Result.success<void>(null);
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export sharing failed (entryCount=$entryCount)',
        error,
        stackTrace,
      );
      return Result.createFailure<void>(
        StorageFailure(
          technicalMessage:
              'Calendar export sharing failed (entryCount=$entryCount)',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<void>> savePreparedCalendarExport({
    required String filePath,
    required String fileName,
    required int entryCount,
  }) async {
    try {
      final baseName = _icsBaseName(fileName);
      final savedPath = await FileSaver.instance.saveAs(
        name: baseName,
        filePath: filePath,
        fileExtension: 'ics',
        mimeType: MimeType.custom,
        customMimeType: 'text/calendar',
      );
      if (savedPath == null || savedPath.isEmpty) {
        AppLogger.i(
          'Calendar export save dismissed by user (entryCount=$entryCount)',
        );
        return Result.createFailure<void>(
          const ValidationFailure(
            technicalMessage:
                'Calendar export save cancelled (reason=user_dismissed)',
            userMessageKey: 'calendarExportSaveCancelled',
          ),
        );
      }
      AppLogger.i(
        'Calendar export saved to user-chosen location (entryCount=$entryCount)',
      );
      return Result.success<void>(null);
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export save failed (entryCount=$entryCount)',
        error,
        stackTrace,
      );
      return Result.createFailure<void>(
        StorageFailure(
          technicalMessage:
              'Calendar export save failed (entryCount=$entryCount)',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<void>> openPreparedCalendarExport({
    required String filePath,
    required int entryCount,
  }) async {
    try {
      final OpenResult openResult = await OpenFile.open(
        filePath,
        type: 'text/calendar',
      );
      if (openResult.type == ResultType.done) {
        AppLogger.i(
          'Calendar export opened with external app (entryCount=$entryCount)',
        );
        return Result.success<void>(null);
      }
      if (openResult.type == ResultType.noAppToOpen) {
        AppLogger.w(
          'Calendar export open failed: no app to handle ics (entryCount=$entryCount)',
        );
        return Result.createFailure<void>(
          const ValidationFailure(
            technicalMessage:
                'Calendar export open failed (reason=no_app_to_open)',
            userMessageKey: 'calendarExportOpenNoApp',
          ),
        );
      }
      AppLogger.w(
        'Calendar export open finished with status (type=${openResult.type.name}, message=${openResult.message}, entryCount=$entryCount)',
      );
      return Result.createFailure<void>(
        ValidationFailure(
          technicalMessage:
              'Calendar export open failed (type=${openResult.type.name}, message=${openResult.message})',
          userMessageKey: 'calendarExportOpenFailed',
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export open threw (entryCount=$entryCount)',
        error,
        stackTrace,
      );
      return Result.createFailure<void>(
        StorageFailure(
          technicalMessage:
              'Calendar export open failed (entryCount=$entryCount)',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _icsBaseName(String fileName) {
    const suffix = '.ics';
    final lower = fileName.toLowerCase();
    if (lower.endsWith(suffix)) {
      return fileName.substring(0, fileName.length - suffix.length);
    }
    return fileName;
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
    final String line = '$key:${_escapeText(value)}';
    return '${_foldIcsContentLine(line)}\r\n';
  }

  /// RFC 5545 §3.1: content lines MUST NOT exceed 75 octets (excluding CRLF);
  /// long lines are folded with CRLF + one SPACE before the next segment.
  String _foldIcsContentLine(String line) {
    const int maxOctetsPerLine = 75;
    final List<String> segments = <String>[];
    final StringBuffer current = StringBuffer();
    int currentOctets = 0;
    for (final int rune in line.runes) {
      final String character = String.fromCharCode(rune);
      final int characterOctets = utf8.encode(character).length;
      if (currentOctets + characterOctets > maxOctetsPerLine &&
          current.isNotEmpty) {
        segments.add(current.toString());
        current
          ..clear()
          ..write(' ');
        currentOctets = 1;
      }
      current.write(character);
      currentOctets += characterOctets;
    }
    if (current.isNotEmpty) {
      segments.add(current.toString());
    }
    return segments.join('\r\n');
  }

  /// RFC 5545 TEXT escaping for property values (SUMMARY, DESCRIPTION, …).
  /// Normalizes line endings first, then escapes `\`, `;`, `,`, and newlines as `\n`.
  String _escapeText(String value) {
    final String normalized = value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    return normalized
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
