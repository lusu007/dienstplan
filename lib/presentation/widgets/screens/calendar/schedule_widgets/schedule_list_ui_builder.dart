import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';

class ScheduleListUiBuilder {
  static Widget buildFilterStatusText({
    required String filterText,
    required String filteredByText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        '$filteredByText: $filterText',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  static Widget buildScheduleItem({
    required Schedule schedule,
    required String serviceName,
    required IconData icon,
    required bool isSelected,
    required Color mainColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? mainColor.withAlpha(20) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? mainColor : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: mainColor.withAlpha(46),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Icon on the left
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mainColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: mainColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Service type and duty group text in the center
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.dutyGroupName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData getDutyTypeIcon(
      String serviceId, Map<String, DutyType>? dutyTypes) {
    final dutyType = dutyTypes?[serviceId];

    // Use the icon from the duty type if available
    if (dutyType?.icon != null) {
      return IconMapper.getIcon(dutyType!.icon!, defaultIcon: Icons.schedule);
    }

    // Fallback to default schedule icon
    return Icons.schedule;
  }

  static Widget buildEmptyState(String noServicesText) {
    return Center(
      child: Text(noServicesText),
    );
  }
}
