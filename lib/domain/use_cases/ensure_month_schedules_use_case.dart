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
    for (final Schedule s in schedules) {
      if (s.configName == configName &&
          s.dutyTypeId.isNotEmpty &&
          s.dutyTypeId != '-') {
        return true;
      }
    }
    return false;
  }
}
