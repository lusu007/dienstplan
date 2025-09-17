import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

class DutyItemList extends StatelessWidget {
  final List<Schedule> schedules;
  final String? selectedDutyGroupName;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final DateTime? selectedDay;
  final Map<String, DutyType>? dutyTypes;
  final bool showFilterStatus;

  const DutyItemList({
    super.key,
    required this.schedules,
    this.selectedDutyGroupName,
    this.onDutyGroupSelected,
    this.scrollController,
    this.selectedDay,
    this.dutyTypes,
    this.showFilterStatus = true, // Default to true for backward compatibility
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with filter status only (conditionally shown)
          if (showFilterStatus)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                selectedDutyGroupName != null
                    ? '${l10n.filteredBy}: $selectedDutyGroupName'
                    : '${l10n.filteredBy}: ${l10n.all}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Duty list - show each schedule separately, not grouped by duty type
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0.0,
              ),
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
                      schedule,
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
          style: TextStyle(fontSize: 16, color: Colors.red.shade600),
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
                    ? mainColor.withAlpha(kAlphaCardSelected)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedDutyGroupName == dutyGroupName
                      ? mainColor
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: selectedDutyGroupName == dutyGroupName ? 2.5 : 1,
                ),
                boxShadow: selectedDutyGroupName == dutyGroupName
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
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor.withAlpha(kAlphaBadge),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dutyTypeName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dutyGroupName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
            style: TextStyle(fontSize: 14, color: Colors.red.shade600),
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
          return IconMapper.getIcon(
            dutyType!.icon!,
            defaultIcon: Icons.schedule,
          );
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
