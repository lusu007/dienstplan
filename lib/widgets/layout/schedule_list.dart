import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/utils/icon_mapper.dart';

class ScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final List<String>? dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
  });

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  List<Schedule> _sortSchedulesByTime(List<Schedule> schedules) {
    return List.from(schedules)
      ..sort((a, b) {
        // Sort by all-day status (all-day services go last)
        if (a.isAllDay && !b.isAllDay) return 1;
        if (!a.isAllDay && b.isAllDay) return -1;

        // For services with same all-day status, sort by duty type order
        final provider = Provider.of<ScheduleProvider>(context, listen: false);
        final activeConfig = provider.activeConfig;

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

  IconData _getDutyTypeIcon(String serviceId, ScheduleProvider provider) {
    final dutyType = provider.activeConfig?.dutyTypes[serviceId];

    // Use the icon from the duty type if available
    if (dutyType?.icon != null) {
      return IconMapper.getIcon(dutyType!.icon!, defaultIcon: Icons.schedule);
    }

    // Fallback to default schedule icon
    return Icons.schedule;
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
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: sortedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = sortedSchedules[index];
        final dutyType = provider.activeConfig?.dutyTypes[schedule.service];
        final serviceName = dutyType?.label ?? schedule.service;
        final serviceTime = dutyType?.isAllDay == true ? l10n.allDay : '';

        final isSelected = widget.selectedDutyGroup == schedule.dutyGroupName;
        final mainColor = Theme.of(context).colorScheme.primary;

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () {
              if (widget.onDutyGroupSelected != null) {
                widget.onDutyGroupSelected!(
                    isSelected ? null : schedule.dutyGroupName);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? mainColor.withAlpha(20) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? mainColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: mainColor.withAlpha(46),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Icon on the left
                    Icon(
                      _getDutyTypeIcon(schedule.service, provider),
                      color: mainColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    // Text content on the right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.dutyGroupName,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (serviceTime.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              serviceTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: mainColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
