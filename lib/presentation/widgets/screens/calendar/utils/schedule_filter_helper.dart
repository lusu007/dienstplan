import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

class ScheduleFilterHelper {
  static List<Schedule> filterSchedules({
    required List<Schedule> schedules,
    required DateTime? selectedDay,
    required DutyScheduleConfig? activeConfig,
    required String? selectedDutyGroup,
  }) {
    if (selectedDay == null || activeConfig == null) {
      return [];
    }

    final filteredSchedules = schedules.where((schedule) {
      final isSameDay = schedule.date.year == selectedDay.year &&
          schedule.date.month == selectedDay.month &&
          schedule.date.day == selectedDay.day;
      final isActiveConfig = schedule.configName == activeConfig.meta.name;
      final isSelectedDutyGroup = selectedDutyGroup == null ||
          schedule.dutyGroupName == selectedDutyGroup;
      return isSameDay && isActiveConfig && isSelectedDutyGroup;
    }).toList();

    return filteredSchedules;
  }

  static String getFilterStatusText(String? selectedDutyGroup, String allText) {
    return selectedDutyGroup ?? allText;
  }
}
