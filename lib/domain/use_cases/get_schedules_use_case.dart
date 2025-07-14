import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class GetSchedulesUseCase {
  final ScheduleRepository _scheduleRepository;

  GetSchedulesUseCase(this._scheduleRepository);

  Future<List<Schedule>> execute() async {
    try {
      AppLogger.i('GetSchedulesUseCase: Executing get schedules');
      final schedules = await _scheduleRepository.getSchedules();
      AppLogger.i(
          'GetSchedulesUseCase: Retrieved ${schedules.length} schedules');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e(
          'GetSchedulesUseCase: Error getting schedules', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Schedule>> executeForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? configName,
  }) async {
    try {
      AppLogger.i(
          'GetSchedulesUseCase: Executing get schedules for date range: $startDate to $endDate${configName != null ? ' for config: $configName' : ''}');

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
          'GetSchedulesUseCase: Retrieved ${schedules.length} schedules for date range');
      return schedules;
    } catch (e, stackTrace) {
      AppLogger.e('GetSchedulesUseCase: Error getting schedules for date range',
          e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearSchedules() async {
    try {
      AppLogger.i('GetSchedulesUseCase: Clearing all schedules');
      await _scheduleRepository.clearSchedules();
      AppLogger.i('GetSchedulesUseCase: All schedules cleared');
    } catch (e, stackTrace) {
      AppLogger.e(
          'GetSchedulesUseCase: Error clearing schedules', e, stackTrace);
      rethrow;
    }
  }
}
