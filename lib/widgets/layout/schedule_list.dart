import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/l10n/app_localizations.dart';

class ScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final List<String>? dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
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

        if (timeA == null || timeB == null || timeA.isEmpty || timeB.isEmpty) {
          return 0;
        }

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

  List<Schedule> _filterSchedules(List<Schedule> schedules) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final selectedDay = provider.selectedDay;
    final activeConfig = provider.activeConfig;

    if (selectedDay == null || activeConfig == null) {
      return [];
    }

    final filteredSchedules = schedules.where((schedule) {
      final isSameDay = schedule.date.year == selectedDay.year &&
          schedule.date.month == selectedDay.month &&
          schedule.date.day == selectedDay.day;
      final isActiveConfig = schedule.configName == activeConfig.meta.name;
      final isSelectedDutyGroup = widget.selectedDutyGroup == null ||
          schedule.dutyGroupName == widget.selectedDutyGroup;
      return isSameDay && isActiveConfig && isSelectedDutyGroup;
    }).toList();

    return filteredSchedules;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filteredSchedules = _filterSchedules(widget.schedules);
    final sortedSchedules = _sortSchedulesByTime(filteredSchedules);
    final provider = Provider.of<ScheduleProvider>(context);

    if (sortedSchedules.isEmpty) {
      return Center(
        child: Text(l10n.noServicesForDay),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = sortedSchedules[index];
        final dutyType = provider.activeConfig?.dutyTypes[schedule.service];
        final serviceName = dutyType?.label ?? schedule.service;
        final serviceTime = dutyType?.isAllDay == true
            ? l10n.allDay
            : '${dutyType?.startTime ?? ''} - ${dutyType?.endTime ?? ''}';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              if (widget.onDutyGroupSelected != null) {
                final isSelected =
                    widget.selectedDutyGroup == schedule.dutyGroupName;
                widget.onDutyGroupSelected!(
                    isSelected ? null : schedule.dutyGroupName);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.dutyGroupName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    serviceTime,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
