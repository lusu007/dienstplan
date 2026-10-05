import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_icon_badge.dart';

class NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing;
  final bool enabled;
  final bool modalTrigger;

  const NavigationCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.trailing,
    this.enabled = true,
    this.modalTrigger = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Widget? effectiveTrailing =
        trailing ??
        (theme.brightness == Brightness.light && enabled && onTap != null
            ? Icon(
                modalTrigger
                    ? Icons.expand_more_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 22,
              )
            : null);

    final Color effectiveTitleColor = enabled
        ? scheme.onSurface
        : scheme.onSurfaceVariant;
    final Color effectiveSubtitleColor = enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurfaceVariant.withValues(alpha: 0.6);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      enabled: enabled,
      modalTrigger: modalTrigger,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GlassIconBadge(icon: icon, tintColor: iconColor, enabled: enabled),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.menuTitle(
                      theme,
                    ).copyWith(color: effectiveTitleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.secondary(
                        theme,
                      ).copyWith(color: effectiveSubtitleColor),
                    ),
                  ],
                ],
              ),
            ),
            if (effectiveTrailing != null) ...[
              const SizedBox(width: 12),
              !enabled
                  ? Opacity(opacity: 0.5, child: effectiveTrailing)
                  : effectiveTrailing,
            ],
          ],
        ),
      ),
    );
  }
}
