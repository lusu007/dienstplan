import 'package:flutter/foundation.dart';
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

    // Debug logging for the "every second month" issue
    debugPrint(
        'EnsureMonth DEBUG: Month ${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')} - '
        'Found ${existing.length} existing schedules, hasValid: $hasValid');
    if (!hasValid && existing.isNotEmpty) {
      debugPrint(
          'EnsureMonth DEBUG: Invalid schedules sample: ${existing.take(3).map((s) => '${s.date.day}:${s.dutyTypeId}').join(', ')}');
    }

    if (hasValid) {
      return existing;
    }
    final List<Schedule> generated = await _generateSchedulesUseCase.execute(
      configName: configName,
      startDate: monthStart,
      endDate: monthEnd,
    );
    debugPrint(
        'EnsureMonth DEBUG: Generated ${generated.length} new schedules for ${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}');
    return generated;
  }

  bool _hasValidSchedules(List<Schedule> schedules, String configName) {
    // Check if we have any schedules for the correct config (including free days with "-")
    final configSchedules =
        schedules.where((s) => s.configName == configName).toList();

    if (configSchedules.isEmpty) {
      debugPrint('EnsureMonth: No schedules found for config $configName');
      return false;
    }

    // Count unique dates - a valid month should have schedules for most days
    final uniqueDates = configSchedules
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    // For a valid month, expect at least 25 days of schedules (accounting for month variations)
    final hasReasonableCoverage = uniqueDates.length >= 25;

    debugPrint(
        'EnsureMonth: Config $configName has ${configSchedules.length} schedules '
        'covering ${uniqueDates.length} days, valid: $hasReasonableCoverage');

    return hasReasonableCoverage;
  }
}
