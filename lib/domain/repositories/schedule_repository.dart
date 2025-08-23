import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<Result<List<Schedule>>> getSchedulesSafe();

  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  });

  Future<Result<List<Schedule>>> getSchedulesForDateRangeSafe({
    required DateTime start,
    required DateTime end,
    String? configName,
  });

  Future<void> saveSchedules(List<Schedule> schedules);
  Future<Result<void>> saveSchedulesSafe(List<Schedule> schedules);

  Future<void> clearSchedules();
  Future<Result<void>> clearSchedulesSafe();

  Future<void> deleteSchedulesByConfigName(String configName);
  Future<Result<void>> deleteSchedulesByConfigNameSafe(String configName);

  Future<List<DutyType>> getDutyTypes({required String configName});
  Future<Result<List<DutyType>>> getDutyTypesSafe({required String configName});
}
