import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/calendar_export_entry.dart';
import 'package:dienstplan/domain/entities/calendar_export_options.dart';
import 'package:dienstplan/domain/entities/calendar_export_payload.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';

class GenerateCalendarExportUseCase {
  final GenerateSchedulesUseCase _generateSchedulesUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final ExceptionMapper _exceptionMapper;

  GenerateCalendarExportUseCase(
    this._generateSchedulesUseCase,
    this._getSettingsUseCase, {
    ExceptionMapper? exceptionMapper,
  }) : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  Future<Result<CalendarExportPayload>> execute(
    CalendarExportOptions options,
  ) async {
    final startDate = options.normalizedStartDate;
    final endDate = options.normalizedEndDate;

    if (startDate.isAfter(endDate)) {
      return Result.createFailure<CalendarExportPayload>(
        const ValidationFailure(
          technicalMessage:
              'Calendar export failed (reason=invalid_date_range)',
          userMessageKey: 'calendarExportInvalidRange',
        ),
      );
    }

    try {
      final settingsResult = await _getSettingsUseCase.execute();
      if (settingsResult.isFailure) {
        return Result.createFailure<CalendarExportPayload>(
          settingsResult.failure,
        );
      }

      final settings = settingsResult.valueIfSuccess;
      final activeConfigName = settings?.activeConfigName;
      if (activeConfigName == null || activeConfigName.isEmpty) {
        return Result.createFailure<CalendarExportPayload>(
          const ValidationFailure(
            technicalMessage:
                'Calendar export failed (reason=missing_active_schedule)',
            userMessageKey: 'calendarExportNoActiveSchedule',
          ),
        );
      }

      final entriesByUid = <String, CalendarExportEntry>{};

      final activeResult = await _generateSchedulesUseCase.execute(
        configName: activeConfigName,
        startDate: startDate,
        endDate: endDate,
      );
      if (activeResult.isFailure) {
        return Result.createFailure<CalendarExportPayload>(
          activeResult.failure,
        );
      }

      for (final entry in _mapScheduleEntries(
        schedules: activeResult.value,
        dutyGroupName: settings?.myDutyGroup,
        summaryPrefix: null,
      )) {
        entriesByUid[entry.uid] = entry;
      }

      if (options.includePartnerSchedule) {
        final partnerConfigName = settings?.partnerConfigName;
        final partnerDutyGroup = settings?.partnerDutyGroup;
        if (partnerConfigName == null ||
            partnerConfigName.isEmpty ||
            partnerDutyGroup == null ||
            partnerDutyGroup.isEmpty) {
          return Result.createFailure<CalendarExportPayload>(
            const ValidationFailure(
              technicalMessage:
                  'Calendar export failed (reason=partner_schedule_unavailable)',
              userMessageKey: 'calendarExportPartnerUnavailable',
            ),
          );
        }

        final partnerResult = await _generateSchedulesUseCase.execute(
          configName: partnerConfigName,
          startDate: startDate,
          endDate: endDate,
        );
        if (partnerResult.isFailure) {
          return Result.createFailure<CalendarExportPayload>(
            partnerResult.failure,
          );
        }

        for (final entry in _mapScheduleEntries(
          schedules: partnerResult.value,
          dutyGroupName: partnerDutyGroup,
          summaryPrefix: options.partnerSummaryPrefix,
        )) {
          entriesByUid[entry.uid] = entry;
        }
      }

      final entries = entriesByUid.values.toList()
        ..sort((a, b) {
          final startCompare = a.startDate.compareTo(b.startDate);
          if (startCompare != 0) {
            return startCompare;
          }
          return a.summary.compareTo(b.summary);
        });

      if (entries.isEmpty) {
        return Result.createFailure<CalendarExportPayload>(
          const ValidationFailure(
            technicalMessage:
                'Calendar export failed (reason=no_entries_available)',
            userMessageKey: 'calendarExportEmpty',
          ),
        );
      }

      AppLogger.i(
        'Calendar export prepared successfully (startDate=${startDate.toIso8601String()}, endDate=${endDate.toIso8601String()}, includePartner=${options.includePartnerSchedule}, entryCount=${entries.length})',
      );

      return Result.success<CalendarExportPayload>(
        CalendarExportPayload(
          calendarName: 'Dienstplan',
          fileName: _buildFileName(startDate, endDate),
          entries: entries,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export failed (startDate=${startDate.toIso8601String()}, endDate=${endDate.toIso8601String()}, includePartner=${options.includePartnerSchedule}, reason=unexpected_error)',
        error,
        stackTrace,
      );
      return Result.createFailure<CalendarExportPayload>(
        _exceptionMapper.mapToFailure(error, stackTrace),
      );
    }
  }

  List<CalendarExportEntry> _mapScheduleEntries({
    required List<Schedule> schedules,
    required String? dutyGroupName,
    required String? summaryPrefix,
  }) {
    final normalizedDutyGroupName = dutyGroupName?.trim();
    final filterByDutyGroup =
        normalizedDutyGroupName != null && normalizedDutyGroupName.isNotEmpty;

    return schedules
        .where(
          (schedule) =>
              !filterByDutyGroup ||
              schedule.dutyGroupName == normalizedDutyGroupName,
        )
        .map((schedule) {
          final includeGroupName = !filterByDutyGroup;
          final summaryBase = includeGroupName
              ? '${schedule.service} (${schedule.dutyGroupName})'
              : schedule.service;
          final summary = summaryPrefix != null && summaryPrefix.isNotEmpty
              ? '$summaryPrefix: $summaryBase'
              : summaryBase;

          return CalendarExportEntry(
            uid: _buildScheduleUid(schedule, summaryPrefix ?? 'primary'),
            summary: summary,
            description:
                'Config: ${schedule.configName}\nGroup: ${schedule.dutyGroupName}',
            startDate: schedule.date,
            endDateExclusive: schedule.date.add(const Duration(days: 1)),
            isAllDay: true,
          );
        })
        .toList();
  }

  String _buildFileName(DateTime startDate, DateTime endDate) {
    return 'dienstplan-${_formatDate(startDate)}-${_formatDate(endDate)}.ics';
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  String _buildScheduleUid(Schedule schedule, String scope) {
    final date = _formatDate(schedule.date);
    return '$scope-${schedule.configName}-${schedule.dutyGroupId}-${schedule.dutyTypeId}-$date'
        .replaceAll(' ', '_');
  }
}
