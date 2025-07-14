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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? mainColor.withAlpha(20) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? mainColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
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
                Icon(
                  icon,
                  color: mainColor,
                  size: 24,
                ),
                const SizedBox(width: 12),

                // Service type text in the center
                Expanded(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Duty group hint on the right
                Text(
                  schedule.dutyGroupName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
