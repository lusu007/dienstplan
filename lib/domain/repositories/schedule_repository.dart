import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<List<Schedule>> getSchedulesForDateRange({
    required DateTime start,
    required DateTime end,
    String? configName,
  });
  Future<void> saveSchedules(List<Schedule> schedules);
  Future<void> clearSchedules();
  Future<List<DutyType>> getDutyTypes({required String configName});
}
