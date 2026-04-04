import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class ScheduleRepository {
  Future<Result<List<Schedule>>> getSchedules();

  Future<Result<List<Schedule>>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  });

  Future<Result<void>> saveSchedules(List<Schedule> schedules);

  Future<Result<void>> clearSchedules();

  Future<Result<void>> deleteSchedulesByConfigName(String configName);

  Future<Result<List<DutyType>>> getDutyTypes({required String configName});

  Future<Result<int>> countSchedulesForMonth({
    required DateTime month,
    String? configName,
  });
}
