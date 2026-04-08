import 'package:dienstplan/core/utils/calendar_date_math.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/schedule_constants.dart';
import 'package:dienstplan/shared/utils/schedule_isolate.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';

class GenerateSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final ConfigRepository _configRepository;
  final ExceptionMapper _exceptionMapper;

  GenerateSchedulesUseCase(
    this._scheduleRepository,
    this._configRepository, {
    ExceptionMapper? exceptionMapper,
  }) : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  Future<Result<List<Schedule>>> execute({
    required String configName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.d(
        'GenerateSchedulesUseCase: Generating schedules for config: $configName from $startDate to $endDate',
      );
      if (startDate.isAfter(endDate)) {
        return Result.createFailure<List<Schedule>>(
          const ValidationFailure(
            technicalMessage: 'Start date cannot be after end date',
          ),
        );
      }
      final Result<List<DutyScheduleConfig>> configsResult =
          await _configRepository.getConfigs();
      if (configsResult.isFailure) {
        return Result.createFailure<List<Schedule>>(configsResult.failure);
      }
      final List<DutyScheduleConfig> configs = configsResult.value;
      DutyScheduleConfig? matched;
      for (final DutyScheduleConfig c in configs) {
        if (c.name == configName) {
          matched = c;
          break;
        }
      }
      if (matched == null) {
        return Result.createFailure<List<Schedule>>(
          ValidationFailure(
            technicalMessage: 'Configuration not found: $configName',
          ),
        );
      }
      final DutyScheduleConfig config = matched;
      final Result<List<Schedule>> existingResult = await _scheduleRepository
          .getSchedulesForDateRange(
            start: startDate,
            end: endDate,
            configName: configName,
          );
      if (existingResult.isFailure) {
        return Result.createFailure<List<Schedule>>(existingResult.failure);
      }
      final List<Schedule> existingSchedules = existingResult.value;
      final int expectedSchedulesPerDay =
          config.expectedSchedulesPerCalendarDay;
      final int inclusiveCalendarDays = utcCalendarInclusiveDayCount(
        startDate,
        endDate,
      );
      final int expectedTotalSchedules =
          inclusiveCalendarDays * expectedSchedulesPerDay;
      const double coverageThreshold = kCoverageThreshold;
      if (existingSchedules.length >=
          expectedTotalSchedules * coverageThreshold) {
        AppLogger.d(
          'GenerateSchedulesUseCase: Found ${existingSchedules.length} existing schedules, checking for gaps',
        );
        final List<DateTime> missingDates = _findMissingDates(
          existingSchedules,
          startDate,
          endDate,
        );
        if (missingDates.isEmpty) {
          AppLogger.d(
            'GenerateSchedulesUseCase: All schedules already exist, returning existing schedules',
          );
          return Result.success<List<Schedule>>(existingSchedules);
        }
        AppLogger.d(
          'GenerateSchedulesUseCase: Generating schedules for ${missingDates.length} missing dates',
        );
        final Result<List<Schedule>> missingResult =
            await _generateForMissingDates(missingDates, config);
        if (missingResult.isFailure) {
          return missingResult;
        }
        final List<Schedule> allSchedules = <Schedule>[
          ...existingSchedules,
          ...missingResult.value,
        ];
        return Result.success<List<Schedule>>(allSchedules);
      }
      final List<Schedule> schedules =
          await ScheduleGenerationIsolate.generateSchedules(
            config: config,
            startDate: startDate,
            endDate: endDate,
          );
      final Result<void> saveResult = await _scheduleRepository.saveSchedules(
        schedules,
      );
      if (saveResult.isFailure) {
        return Result.createFailure<List<Schedule>>(saveResult.failure);
      }
      AppLogger.d(
        'GenerateSchedulesUseCase: Generated and saved ${schedules.length} schedules',
      );
      return Result.success<List<Schedule>>(schedules);
    } catch (e, stackTrace) {
      AppLogger.e(
        'GenerateSchedulesUseCase: Error generating schedules',
        e,
        stackTrace,
      );
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  List<DateTime> _findMissingDates(
    List<Schedule> existingSchedules,
    DateTime startDate,
    DateTime endDate,
  ) {
    final Set<DateTime> existingDates = existingSchedules
        .map((Schedule s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
    final List<DateTime> missingDates = <DateTime>[];
    for (
      DateTime date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      if (!existingDates.contains(normalizedDate)) {
        missingDates.add(normalizedDate);
      }
    }
    return missingDates;
  }

  Future<Result<List<Schedule>>> _generateForMissingDates(
    List<DateTime> missingDates,
    DutyScheduleConfig config,
  ) async {
    if (missingDates.isEmpty) {
      return Result.success<List<Schedule>>(<Schedule>[]);
    }

    final List<_DateSpan> missingSpans = _groupConsecutiveDates(missingDates);
    final List<Schedule> schedules = <Schedule>[];

    for (final _DateSpan span in missingSpans) {
      final List<Schedule> generated =
          await ScheduleGenerationIsolate.generateSchedules(
            config: config,
            startDate: span.startDate,
            endDate: span.endDate,
          );
      schedules.addAll(generated);
    }

    final Result<void> saveResult = await _scheduleRepository.saveSchedules(
      schedules,
    );
    if (saveResult.isFailure) {
      return Result.createFailure<List<Schedule>>(saveResult.failure);
    }
    return Result.success<List<Schedule>>(schedules);
  }

  List<_DateSpan> _groupConsecutiveDates(List<DateTime> dates) {
    if (dates.isEmpty) {
      return const <_DateSpan>[];
    }

    final List<_DateSpan> spans = <_DateSpan>[];
    DateTime spanStart = dates.first;
    DateTime previous = dates.first;

    for (int i = 1; i < dates.length; i++) {
      final DateTime current = dates[i];
      final bool isConsecutive = current.difference(previous).inDays == 1;

      if (!isConsecutive) {
        spans.add(_DateSpan(startDate: spanStart, endDate: previous));
        spanStart = current;
      }

      previous = current;
    }

    spans.add(_DateSpan(startDate: spanStart, endDate: previous));
    return spans;
  }
}

class _DateSpan {
  final DateTime startDate;
  final DateTime endDate;

  const _DateSpan({required this.startDate, required this.endDate});
}
