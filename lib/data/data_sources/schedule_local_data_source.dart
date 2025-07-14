import 'package:dienstplan/domain/entities/schedule.dart';

abstract class ScheduleLocalDataSource {
  /// Get all schedules from local storage
  Future<List<Schedule>> getSchedules();

  /// Get schedules for a specific date range
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save schedules to local storage
  Future<void> saveSchedules(List<Schedule> schedules);

  /// Save a single schedule to local storage
  Future<void> saveSchedule(Schedule schedule);

  /// Clear all schedules from local storage
  Future<void> clearSchedules();

  /// Delete schedules for a specific date range
  Future<void> deleteSchedulesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get duty types for a specific configuration
  Future<List<String>> getDutyTypes({required String configName});

  /// Get duty groups for a specific configuration
  Future<List<String>> getDutyGroups({required String configName});
}
