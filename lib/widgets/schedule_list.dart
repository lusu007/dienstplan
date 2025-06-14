import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule.dart';
import '../models/duty_schedule_config.dart';
import '../utils/logger.dart';
import 'dart:math' as math;

class ScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final List<String> dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?) onDutyGroupSelected;

  const ScheduleList({
    super.key,
    required this.schedules,
    required this.dutyGroups,
    required this.selectedDutyGroup,
    required this.onDutyGroupSelected,
  });

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  List<Schedule> _sortSchedulesByTime(List<Schedule> schedules) {
    return List.from(schedules)
      ..sort((a, b) {
        // First sort by all-day status (all-day services go last)
        if (a.isAllDay && !b.isAllDay) return 1;
        if (!a.isAllDay && b.isAllDay) return -1;
        if (a.isAllDay && b.isAllDay) return 0;

        // For non-all-day services, sort by start time
        final provider = Provider.of<ScheduleProvider>(context, listen: false);
        final dutyTypeA = provider.activeConfig?.dutyTypes[a.service];
        final dutyTypeB = provider.activeConfig?.dutyTypes[b.service];

        if (dutyTypeA == null || dutyTypeB == null) return 0;

        final timeA = dutyTypeA.startTime;
        final timeB = dutyTypeB.startTime;

        if (timeA == null || timeB == null || timeA.isEmpty || timeB.isEmpty)
          return 0;

        // Parse times to compare them properly
        final timeAParts = timeA.split(':');
        final timeBParts = timeB.split(':');

        if (timeAParts.length != 2 || timeBParts.length != 2) return 0;

        final timeAValue =
            int.parse(timeAParts[0]) * 60 + int.parse(timeAParts[1]);
        final timeBValue =
            int.parse(timeBParts[0]) * 60 + int.parse(timeBParts[1]);

        return timeAValue.compareTo(timeBValue);
      });
  }

  List<Schedule> _filterSchedules() {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final selectedDay = provider.selectedDay;
    final activeConfig = provider.activeConfig;
    final selectedDutyGroup = widget.selectedDutyGroup;
    final schedules = widget.schedules;

    if (selectedDay == null || activeConfig == null) {
      return [];
    }

    // First filter by date and active config
    final filteredSchedules = schedules.where((schedule) {
      // Filter by date (exact match for year, month, and day)
      final isSameDay = schedule.date.year == selectedDay!.year &&
          schedule.date.month == selectedDay!.month &&
          schedule.date.day == selectedDay!.day;

      // Filter by active configuration
      final isActiveConfig = schedule.configName == activeConfig!.meta.name;

      return isSameDay && isActiveConfig;
    }).toList();

    // Remove duplicates by keeping only the first schedule for each duty group
    final uniqueSchedules = <String, Schedule>{};
    for (final schedule in filteredSchedules) {
      if (!uniqueSchedules.containsKey(schedule.dutyGroupId)) {
        uniqueSchedules[schedule.dutyGroupId] = schedule;
      }
    }

    // Convert back to list and filter by selected duty group if needed
    var result = uniqueSchedules.values.toList();
    if (selectedDutyGroup != null) {
      result =
          result.where((s) => s.dutyGroupName == selectedDutyGroup).toList();
    }

    // Sort schedules
    result.sort((a, b) {
      // First sort by all-day status
      if (a.isAllDay != b.isAllDay) {
        return a.isAllDay ? 1 : -1;
      }

      // Then sort by start time
      final dutyTypeA = activeConfig!.dutyTypes[a.service];
      final dutyTypeB = activeConfig!.dutyTypes[b.service];

      if (dutyTypeA != null && dutyTypeB != null) {
        if (dutyTypeA.startTime != null && dutyTypeB.startTime != null) {
          return dutyTypeA.startTime!.compareTo(dutyTypeB.startTime!);
        }
      }

      // Finally sort by service name
      return a.service.compareTo(b.service);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _filterSchedules();
    final sortedSchedules = _sortSchedulesByTime(filteredSchedules);
    final provider = Provider.of<ScheduleProvider>(context);

    if (sortedSchedules.isEmpty) {
      return Column(
        children: [
          // Schedule List
          Expanded(
            child: sortedSchedules.isEmpty
                ? const Center(
                    child: Text('Keine Dienste für diesen Tag'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = sortedSchedules[index];
                      final isSelected =
                          widget.selectedDutyGroup == schedule.dutyGroupName;
                      final dutyType =
                          provider.activeConfig?.dutyTypes[schedule.service];
                      final serviceName = dutyType?.label ?? schedule.service;
                      final serviceTime = dutyType?.allDay == true
                          ? 'Ganztägig'
                          : '${dutyType?.startTime ?? ''} - ${dutyType?.endTime ?? ''}';

                      return ListTile(
                        title: Text(serviceName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(schedule.dutyGroupName),
                            Text(serviceTime),
                          ],
                        ),
                        selected: isSelected,
                        onTap: () {
                          widget.onDutyGroupSelected(
                              isSelected ? null : schedule.dutyGroupName);
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // Schedule List
          Expanded(
            child: sortedSchedules.isEmpty
                ? const Center(
                    child: Text('Keine Dienste für diesen Tag'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = sortedSchedules[index];
                      final isSelected =
                          widget.selectedDutyGroup == schedule.dutyGroupName;
                      final dutyType =
                          provider.activeConfig?.dutyTypes[schedule.service];
                      final serviceName = dutyType?.label ?? schedule.service;
                      final serviceTime = dutyType?.allDay == true
                          ? 'Ganztägig'
                          : '${dutyType?.startTime ?? ''} - ${dutyType?.endTime ?? ''}';

                      return ListTile(
                        title: Text(serviceName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(schedule.dutyGroupName),
                            Text(serviceTime),
                          ],
                        ),
                        selected: isSelected,
                        onTap: () {
                          widget.onDutyGroupSelected(
                              isSelected ? null : schedule.dutyGroupName);
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    }
  }
}
