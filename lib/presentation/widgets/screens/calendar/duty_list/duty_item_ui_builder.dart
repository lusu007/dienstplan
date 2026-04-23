import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

class DutyItemUiBuilder {
  static Widget buildDutyItem({
    required BuildContext context,
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
              color: isSelected
                  ? mainColor.withAlpha(kAlphaCardSelected)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? mainColor
                    : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: mainColor.withAlpha(kAlphaShadowStrong),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withAlpha(kAlphaShadowWeak),
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
                    color: mainColor.withAlpha(kAlphaBadge),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: mainColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Service type and duty group text in the center
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          serviceName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.dutyGroupName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  static IconData iconForSchedule(
    Schedule schedule,
    Map<String, DutyType>? dutyTypes,
  ) {
    if (schedule.isUserDefined) {
      if (schedule.personalEntryKind ==
          PersonalCalendarEntryKind.personalDuty) {
        return Icons.work_history_outlined;
      }
      return Icons.event_outlined;
    }
    return getDutyTypeIcon(schedule.dutyTypeId, dutyTypes);
  }

  static IconData getDutyTypeIcon(
    String serviceId,
    Map<String, DutyType>? dutyTypes,
  ) {
    final dutyType = dutyTypes?[serviceId];

    // Use the icon from the duty type if available
    if (dutyType?.icon != null) {
      return IconMapper.getIcon(dutyType!.icon!, defaultIcon: Icons.schedule);
    }

    // Fallback to default schedule icon
    return Icons.schedule;
  }

  static Widget buildEmptyState(String noServicesText) {
    return Center(child: Text(noServicesText));
  }
}
