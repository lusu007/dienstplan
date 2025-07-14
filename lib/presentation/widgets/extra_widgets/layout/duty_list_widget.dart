import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';

class DutyListWidget extends StatelessWidget {
  final List<Schedule> schedules;
  final String? selectedDutyGroupName;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final DateTime? selectedDay;
  final Map<String, DutyType>? dutyTypes;

  const DutyListWidget({
    super.key,
    required this.schedules,
    this.selectedDutyGroupName,
    this.onDutyGroupSelected,
    this.scrollController,
    this.selectedDay,
    this.dutyTypes,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final l10n = AppLocalizations.of(context);
      final mainColor = Theme.of(context).colorScheme.primary;

      if (schedules.isEmpty) {
        return Center(
          child: Text(
            l10n.noServicesForDay,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with filter status only
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              selectedDutyGroupName != null
                  ? '${l10n.filteredBy}: ${selectedDutyGroupName}'
                  : '${l10n.filteredBy}: ${l10n.all}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Duty list - show each schedule separately, not grouped by duty type
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                try {
                  final schedule = schedules[index];
                  final dutyGroupName = schedule.dutyGroupName;

                  final dutyItem = _buildDutyItem(
                    context,
                    dutyGroupName,
                    schedule,
                    [
                      schedule
                    ], // Pass single schedule instead of grouped schedules
                    false, // No selection for now
                    mainColor,
                  );
                  return dutyItem;
                } catch (e, stackTrace) {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      // Return a safe fallback widget
      return Center(
        child: Text(
          'Error loading duties',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red.shade600,
          ),
        ),
      );
    }
  }

  Widget _buildDutyItem(
    BuildContext context,
    String dutyGroupName,
    Schedule schedule,
    List<Schedule> dutySchedules,
    bool isSelected,
    Color mainColor,
  ) {
    try {
      final dutyDisplayName = dutyGroupName;
      final dutyTypeName = _getDutyTypeDisplayName(schedule.dutyTypeId);

      // Simplified card structure
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () {
            if (onDutyGroupSelected != null) {
              // Toggle filter: if already selected, clear filter; otherwise, set filter
              final newFilter =
                  selectedDutyGroupName == dutyGroupName ? null : dutyGroupName;
              onDutyGroupSelected!(newFilter);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: selectedDutyGroupName == dutyGroupName
                  ? mainColor.withAlpha(100)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mainColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDutyTypeIcon(schedule.dutyTypeId),
                    color: mainColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Duty information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dutyTypeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dutyGroupName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (selectedDutyGroupName == dutyGroupName)
                  Icon(
                    Icons.check_circle,
                    color: mainColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      // Return a simple fallback widget
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading duty',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
        ),
      );
    }
  }

  String _getDutyGroupDisplayName(
      String dutyGroupName, List<Schedule> schedules) {
    try {
      // Simply return the duty group name since we're filtering by duty groups
      return dutyGroupName;
    } catch (e, stackTrace) {
      return dutyGroupName; // Fallback to duty group name
    }
  }

  IconData _getDutyTypeIcon(String dutyTypeId) {
    try {
      // Use the icon from the duty type configuration if available
      if (dutyTypes != null && dutyTypes!.containsKey(dutyTypeId)) {
        final dutyType = dutyTypes![dutyTypeId];
        if (dutyType?.icon != null) {
          return IconMapper.getIcon(dutyType!.icon!,
              defaultIcon: Icons.schedule);
        }
      }

      // Fallback to default schedule icon
      return Icons.schedule;
    } catch (e, stackTrace) {
      return Icons.schedule; // Fallback icon
    }
  }

  String _getDutyTypeDisplayName(String dutyTypeId) {
    try {
      // Use the label from the duty type configuration if available
      if (dutyTypes != null && dutyTypes!.containsKey(dutyTypeId)) {
        final dutyType = dutyTypes![dutyTypeId];
        if (dutyType?.label != null) {
          return dutyType!.label;
        }
      }

      // Fallback to hardcoded mapping for common duty types
      switch (dutyTypeId) {
        case 'F':
          return 'Frühdienst';
        case 'S':
          return 'Spätdienst';
        case 'N':
          return 'Nachtdienst';
        case 'ZD':
          return 'Zusatzdienst';
        case '-':
          return 'Frei';
        default:
          return dutyTypeId;
      }
    } catch (e, stackTrace) {
      return dutyTypeId; // Fallback to duty type ID
    }
  }
}
