import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';

/// Small uppercase-style label above form sections (matches personal entry sheet).
class GlassFormSectionEyebrow extends StatelessWidget {
  const GlassFormSectionEyebrow({
    super.key,
    required this.text,
    required this.enabled,
  });

  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(
          alpha: enabled ? 1.0 : 0.5,
        ),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Tappable glass row that expands/collapses (e.g. to reveal [CalendarDatePicker]).
class GlassInlineExpandTile extends StatelessWidget {
  const GlassInlineExpandTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isExpanded,
    this.enabled = true,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foreground = colorScheme.onSurface.withValues(
      alpha: enabled ? 1.0 : 0.5,
    );
    final Color trailing = colorScheme.onSurfaceVariant.withValues(
      alpha: enabled ? 1.0 : 0.5,
    );
    return GlassCard(
      onTap: onTap,
      enabled: enabled,
      padding: const EdgeInsets.symmetric(
        horizontal: glassSpacingMd,
        vertical: glassSpacingMd,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: trailing),
          const SizedBox(width: glassSpacingMd),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            enabled && isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: trailing,
          ),
        ],
      ),
    );
  }
}
