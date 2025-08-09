import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/domain/use_cases/get_schedules_use_case.dart';

class EnsureMonthSchedulesUseCase {
  final GetSchedulesUseCase _getSchedulesUseCase;
  final GenerateSchedulesUseCase _generateSchedulesUseCase;

  EnsureMonthSchedulesUseCase(
    this._getSchedulesUseCase,
    this._generateSchedulesUseCase,
  );

  Future<List<Schedule>> execute({
    required String configName,
    required DateTime monthStart,
  }) async {
    final DateTime monthEnd =
        DateTime(monthStart.year, monthStart.month + 1, 0);
    final List<Schedule> existing =
        await _getSchedulesUseCase.executeForDateRange(
      startDate: monthStart,
      endDate: monthEnd,
      configName: configName,
    );
    final bool hasValid = _hasValidSchedules(existing, configName);

    if (hasValid) {
      return existing;
    }
    final List<Schedule> generated = await _generateSchedulesUseCase.execute(
      configName: configName,
      startDate: monthStart,
      endDate: monthEnd,
    );

    return generated;
  }

  bool _hasValidSchedules(List<Schedule> schedules, String configName) {
    // Check if we have any schedules for the correct config (including free days with "-")
    final configSchedules =
        schedules.where((s) => s.configName == configName).toList();

    if (configSchedules.isEmpty) {
      return false;
    }

    // Count unique dates - a valid month should have schedules for most days
    final uniqueDates = configSchedules
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    // For a valid month, expect at least 25 days of schedules (accounting for month variations)
    final hasReasonableCoverage = uniqueDates.length >= 25;

    return hasReasonableCoverage;
  }
}
