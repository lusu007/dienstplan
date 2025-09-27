import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color iconColor;
  final bool enabled;

  const ToggleCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.iconColor = AppColors.primary,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    // Use disabled colors when not enabled
    final Color effectiveIconColor = enabled
        ? iconColor
        : theme.colorScheme.onSurfaceVariant;
    final Color effectiveTitleColor = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    final Color effectiveSubtitleColor = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: effectiveIconColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: effectiveTitleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: subtitle != null
                            ? Text(
                                subtitle!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: effectiveSubtitleColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Switch(
                        value: value,
                        onChanged: enabled ? onChanged : null,
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
