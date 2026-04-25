import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';

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
  final bool useGlossyHighlight;

  const GlassIconBadge({
    super.key,
    required this.icon,
    this.tintColor,
    this.enabled = true,
    this.size = 40,
    this.useGlossyHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tint = tintColor ?? colorScheme.primary;
    final double opacity = enabled ? 1.0 : 0.4;
    final bool isGlossy = useGlossyHighlight;
    final Color solidTint = tint;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isGlossy ? null : solidTint.withValues(alpha: opacity),
        gradient: isGlossy
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(
                    alpha:
                        (isDark
                            ? glassIconBadgeGradientTopAlphaDark
                            : glassIconBadgeGradientTopAlphaLight) *
                        opacity,
                  ),
                  tint.withValues(
                    alpha:
                        (isDark
                            ? glassIconBadgeGradientBottomAlphaDark
                            : glassIconBadgeGradientBottomAlphaLight) *
                        opacity,
                  ),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: isGlossy
              ? Colors.white.withValues(
                  alpha:
                      (isDark
                          ? glassIconBadgeBorderAlphaDark
                          : glassIconBadgeBorderAlphaLight) *
                      opacity,
                )
              : Colors.transparent,
          width: isGlossy ? 1 : 0,
        ),
        boxShadow: enabled && isGlossy
            ? [
                BoxShadow(
                  color: tint.withValues(
                    alpha: isDark
                        ? glassIconBadgeShadowAlphaDark
                        : glassIconBadgeShadowAlphaLight,
                  ),
                  blurRadius: glassIconBadgeShadowBlur,
                  offset: const Offset(0, glassIconBadgeShadowOffsetY),
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
