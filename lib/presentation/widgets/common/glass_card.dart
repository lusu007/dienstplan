import 'package:flutter/material.dart';

/// Glass-morphism card surface used across the settings screen and its
/// sub-screens.
///
/// Provides a translucent tinted background with a subtle white border. When
/// [isActive] is true the card is rendered with a primary tint overlay and a
/// soft glow so it stands out as the selected option.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isActive;
  final bool enabled;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.isActive = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double enabledMul = enabled ? 1.0 : 0.55;

    final Color baseBackground = Colors.white.withValues(
      alpha: (isDark ? 0.06 : 0.28) * enabledMul,
    );
    final Color activeBackground = colorScheme.primary.withValues(
      alpha: (isDark ? 0.22 : 0.18) * enabledMul,
    );
    final Color baseBorder = Colors.white.withValues(
      alpha: (isDark ? 0.14 : 0.45) * enabledMul,
    );
    final Color activeBorder = colorScheme.primary.withValues(
      alpha: 0.85 * enabledMul,
    );

    final Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isActive ? activeBackground : baseBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isActive ? activeBorder : baseBorder,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(
                    alpha: (isDark ? 0.32 : 0.25) * enabledMul,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: child,
    );

    final EdgeInsetsGeometry effectiveMargin = margin ?? EdgeInsets.zero;

    if (onTap == null) {
      return Padding(padding: effectiveMargin, child: card);
    }

    return Padding(
      padding: effectiveMargin,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      ),
    );
  }
}
