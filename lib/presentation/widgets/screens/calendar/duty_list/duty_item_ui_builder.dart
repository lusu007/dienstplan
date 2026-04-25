import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';

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
    const EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    );
    final double glassContentHeight = (72 - contentPadding.vertical).toDouble();
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: contentPadding,
      borderRadius: 16,
      isActive: isSelected,
      onTap: onTap,
      child: SizedBox(
        height: glassContentHeight,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor.withAlpha(kAlphaBadge),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: mainColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      serviceName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
