import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';

class SelectionCard extends StatelessWidget {
  final dynamic title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? mainColor;
  final double? iconSize;
  final EdgeInsets? contentPadding;
  final double? minVerticalPadding;
  final bool useDialogStyle;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.isSelected,
    required this.onTap,
    this.mainColor,
    this.iconSize,
    this.contentPadding,
    this.minVerticalPadding,
    this.useDialogStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = mainColor ?? scheme.primary;

    if (useDialogStyle) {
      return _buildDialogStyle(context, theme, scheme, accent);
    }
    return _buildGeneralStyle(context, theme, scheme, accent);
  }

  Widget _buildDialogStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    Color accent,
  ) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      isActive: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? accent : scheme.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(theme, scheme),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: isSelected
                            ? scheme.onSurface.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    Color accent,
  ) {
    final double size = iconSize ?? 32;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      isActive: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: accent, size: size),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(theme, scheme),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? accent : scheme.onSurfaceVariant,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ColorScheme scheme) {
    if (title is Widget) {
      return title as Widget;
    }
    return Text(
      title as String,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: scheme.onSurface,
      ),
    );
  }
}
