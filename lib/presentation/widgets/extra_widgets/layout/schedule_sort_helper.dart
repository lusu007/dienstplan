import 'package:dienstplan/data/models/schedule.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

class ScheduleSortHelper {
  static List<Schedule> sortSchedulesByTime(
    List<Schedule> schedules,
    DutyScheduleConfig? activeConfig,
  ) {
    return List.from(schedules)
      ..sort((a, b) {
        // Sort by all-day status (all-day services go last)
        if (a.isAllDay && !b.isAllDay) return 1;
        if (!a.isAllDay && b.isAllDay) return -1;

        // For services with same all-day status, sort by duty type order
        if (activeConfig == null) {
          // Fallback to alphabetical sorting if no config available
          final dutyTypeA = activeConfig?.dutyTypes[a.service];
          final dutyTypeB = activeConfig?.dutyTypes[b.service];

          final labelA = dutyTypeA?.label ?? a.service;
          final labelB = dutyTypeB?.label ?? b.service;

          return labelA.compareTo(labelB);
        }

        final orderA = activeConfig.dutyTypeOrder.indexOf(a.service);
        final orderB = activeConfig.dutyTypeOrder.indexOf(b.service);

        // If both services are in the order list, sort by their position
        if (orderA != -1 && orderB != -1) {
          return orderA.compareTo(orderB);
        }

        // If only one service is in the order list, prioritize it
        if (orderA != -1) return -1;
        if (orderB != -1) return 1;

        // If neither service is in the order list, sort alphabetically
        final dutyTypeA = activeConfig.dutyTypes[a.service];
        final dutyTypeB = activeConfig.dutyTypes[b.service];

        final labelA = dutyTypeA?.label ?? a.service;
        final labelB = dutyTypeB?.label ?? b.service;

        return labelA.compareTo(labelB);
      });
  }
}
