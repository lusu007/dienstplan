import 'package:flutter/material.dart';

/// Filled, primary-tinted icon badge used inside glass settings cards.
///
/// Provides a solid coloured square on which a white icon sits, mirroring
/// the iOS-settings category icons. This keeps icons readable even when the
/// glass card is rendered on top of the primary-tinted aurora backdrop.
class GlassIconBadge extends StatelessWidget {
  final IconData icon;
  final Color? tintColor;
  final bool enabled;
  final double size;

  const GlassIconBadge({
    super.key,
    required this.icon,
    this.tintColor,
    this.enabled = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tint = tintColor ?? colorScheme.primary;
    final double opacity = enabled ? 1.0 : 0.4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: (isDark ? 0.85 : 0.95) * opacity),
            tint.withValues(alpha: (isDark ? 0.55 : 0.70) * opacity),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: (isDark ? 0.20 : 0.35) * opacity,
          ),
          width: 1,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: tint.withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : const [],
      ),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: opacity),
        size: size * 0.55,
      ),
    );
  }
}
