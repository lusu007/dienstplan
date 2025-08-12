import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class DutyGroupCard extends StatelessWidget {
  final String dutyGroupName;
  final bool isSelected;
  final VoidCallback onTap;

  const DutyGroupCard({
    super.key,
    required this.dutyGroupName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionCard(
      title: dutyGroupName,
      leadingIcon: Icons.group,
      isSelected: isSelected,
      onTap: onTap,
      mainColor: AppColors.primary,
    );
  }
}
