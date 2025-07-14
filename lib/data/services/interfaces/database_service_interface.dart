import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/data/models/settings.dart';

abstract class DatabaseServiceInterface {
  Future<void> initialize();
  Future<void> close();

  // Schedule operations
  Future<List<Schedule>> getSchedules();
  Future<List<Schedule>> getSchedulesForDateRange(
      DateTime startDate, DateTime endDate);
  Future<void> saveSchedule(Schedule schedule);
  Future<void> saveSchedules(List<Schedule> schedules);
  Future<void> deleteSchedule(String id);
  Future<void> clearSchedules();

  // Settings operations
  Future<Settings?> getSettings();
  Future<void> saveSettings(Settings settings);
  Future<void> clearSettings();

  // Utility operations
  Future<bool> hasData();
  Future<void> clearAllData();
}
