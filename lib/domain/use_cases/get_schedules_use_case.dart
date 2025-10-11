import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/repositories/schedule_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class GetSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;
  final ExceptionMapper _exceptionMapper;

  GetSchedulesUseCase(this._scheduleRepository)
    : _exceptionMapper = const ExceptionMapper();

  Future<List<Schedule>> execute() async {
    try {
      AppLogger.i('GetSchedulesUseCase: Executing get schedules');
      final schedules = await _scheduleRepository.getSchedules();
      AppLogger.i(
        'GetSchedulesUseCase: Retrieved ${schedules.length} schedules',
      );
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e(
        'GetSchedulesUseCase: Error getting schedules',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<Result<List<Schedule>>> executeSafe() async {
    try {
      final result = await execute();
      return Result.success<List<Schedule>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  Future<List<Schedule>> executeForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async {
    try {
      AppLogger.i(
        'GetSchedulesUseCase: Executing get schedules for date range: $startDate to $endDate${configName != null ? ' for config: $configName' : ''}',
      );

      // Business logic: Validate date range
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('Start date cannot be after end date');
      }

      final schedules = await _scheduleRepository.getSchedulesForDateRange(
        start: startDate,
        end: endDate,
        configName: configName,
      );

      AppLogger.i(
        'GetSchedulesUseCase: Retrieved ${schedules.length} schedules for date range',
      );
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e(
        'GetSchedulesUseCase: Error getting schedules for date range',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<Result<List<Schedule>>> executeForDateRangeSafe({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async {
    try {
      final result = await executeForDateRange(
        startDate: startDate,
        endDate: endDate,
        configName: configName,
      );
      return Result.success<List<Schedule>>(result);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<List<Schedule>>(failure);
    }
  }

  Future<void> clearSchedules() async {
    try {
      AppLogger.i('GetSchedulesUseCase: Clearing all schedules');
      await _scheduleRepository.clearSchedules();
      AppLogger.i('GetSchedulesUseCase: All schedules cleared');
    } catch (e, stackTrace) {
      AppLogger.e(
        'GetSchedulesUseCase: Error clearing schedules',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<Result<void>> clearSchedulesSafe() async {
    try {
      await clearSchedules();
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }
}
