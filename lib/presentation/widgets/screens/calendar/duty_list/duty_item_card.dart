import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_ui_builder.dart';

class DutyItemCard extends StatelessWidget {
  final Schedule schedule;
  final String serviceName;
  final IconData icon;
  final bool isSelected;
  final Color mainColor;
  final VoidCallback? onTap;
  final bool showDutyGroup;

  const DutyItemCard({
    super.key,
    required this.schedule,
    required this.serviceName,
    required this.icon,
    required this.isSelected,
    required this.mainColor,
    this.onTap,
    this.showDutyGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    return DutyItemUiBuilder.buildDutyItem(
      context: context,
      schedule: schedule,
      serviceName: serviceName,
      icon: icon,
      isSelected: isSelected,
      mainColor: mainColor,
      onTap: onTap,
    );
  }
}

class DutyItemCardList extends StatelessWidget {
  final List<Schedule> schedules;
  final Map<String, dynamic>? dutyTypes;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const DutyItemCardList({
    super.key,
    required this.schedules,
    this.dutyTypes,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).colorScheme.primary;

    return ListView.builder(
      controller: scrollController,
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final serviceName = schedule.service; // Simplified for now
        final isSelected = selectedDutyGroup == schedule.dutyGroupName;

        return DutyItemCard(
          schedule: schedule,
          serviceName: serviceName,
          icon: DutyItemUiBuilder.getDutyTypeIcon(
            schedule.service,
            null, // Simplified for now
          ),
          isSelected: isSelected,
          mainColor: mainColor,
          onTap: () {
            if (onDutyGroupSelected != null) {
              onDutyGroupSelected!(isSelected ? null : schedule.dutyGroupName);
            }
          },
        );
      },
    );
  }
}
