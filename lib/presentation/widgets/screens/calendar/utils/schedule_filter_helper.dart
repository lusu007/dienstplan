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
      // Normalize dates to avoid timezone issues
      final scheduleDate =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      final selectedDate =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      final isSameDay = scheduleDate.isAtSameMomentAs(selectedDate);

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
