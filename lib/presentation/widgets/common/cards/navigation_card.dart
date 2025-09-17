import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color iconColor;
  final Widget? trailing;
  final bool enabled;

  const NavigationCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.trailing,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final effectiveIconColor = enabled ? iconColor : scheme.onSurfaceVariant;
    final effectiveTitleColor = enabled
        ? scheme.onSurface
        : scheme.onSurfaceVariant;
    final effectiveSubtitleColor = enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            color: enabled
                ? theme.cardColor
                : theme.cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? scheme.outlineVariant
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            minVerticalPadding: 20,
            leading: Icon(icon, color: effectiveIconColor, size: 40),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: effectiveTitleColor,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: effectiveSubtitleColor,
                    ),
                  )
                : null,
            trailing: trailing != null && !enabled
                ? Opacity(opacity: 0.5, child: trailing!)
                : trailing,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            selectedTileColor: Colors.transparent,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
