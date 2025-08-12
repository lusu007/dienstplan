import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';

class ConfigCard extends StatelessWidget {
  final DutyScheduleConfig config;
  final bool isSelected;
  final VoidCallback onTap;

  const ConfigCard({
    super.key,
    required this.config,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getConfigIcon() {
    if (config.meta.icon != null) {
      return IconMapper.getIcon(config.meta.icon, defaultIcon: Icons.schedule);
    }
    return Icons.directions_car;
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = _getConfigIcon();

    return SelectionCard(
      title: config.meta.name,
      subtitle: config.meta.description,
      leadingIcon: icon,
      isSelected: isSelected,
      onTap: onTap,
      mainColor: AppColors.primary,
    );
  }
}
