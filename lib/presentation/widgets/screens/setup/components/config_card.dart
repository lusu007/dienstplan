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
      title: _buildTitle(),
      subtitle: config.meta.description.isNotEmpty
          ? config.meta.description
          : null,
      leadingIcon: icon,
      isSelected: isSelected,
      onTap: onTap,
      mainColor: AppColors.primary,
    );
  }

  Widget _buildTitle() {
    if (config.meta.policeAuthority != null &&
        config.meta.policeAuthority!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.meta.policeAuthority!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(config.meta.name),
        ],
      );
    }
    return Text(config.meta.name);
  }
}
