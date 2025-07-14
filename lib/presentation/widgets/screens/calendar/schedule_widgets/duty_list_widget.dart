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
                  ? '${l10n.filteredBy}: $selectedDutyGroupName'
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
                } catch (e) {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      );
    } catch (e) {
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
      final dutyTypeName = _getDutyTypeDisplayName(schedule.dutyTypeId);

      // Simplified card structure
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onDutyGroupSelected != null) {
                // Toggle filter: if already selected, clear filter; otherwise, set filter
                final newFilter = selectedDutyGroupName == dutyGroupName
                    ? null
                    : dutyGroupName;
                onDutyGroupSelected!(newFilter);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: selectedDutyGroupName == dutyGroupName
                    ? mainColor.withAlpha(20)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedDutyGroupName == dutyGroupName
                      ? mainColor
                      : Colors.grey.shade300,
                  width: selectedDutyGroupName == dutyGroupName ? 2.5 : 1,
                ),
                boxShadow: selectedDutyGroupName == dutyGroupName
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
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dutyTypeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dutyGroupName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
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
    } catch (e) {
      // Return a simple fallback widget
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
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
    } catch (e) {
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
    } catch (e) {
      return dutyTypeId; // Fallback to duty type ID
    }
  }
}
