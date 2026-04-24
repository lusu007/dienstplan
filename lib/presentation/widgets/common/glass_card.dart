import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';

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
  final Color? tintColor;
  final double? tintAlpha;
  final Color? borderColor;
  final double? borderAlpha;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = glassSurfaceRadiusMd,
    this.isActive = false,
    this.enabled = true,
    this.onTap,
    this.tintColor,
    this.tintAlpha,
    this.borderColor,
    this.borderAlpha,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double enabledMul = enabled ? 1.0 : 0.55;

    final Color baseBackground = Colors.white.withValues(
      alpha:
          (isDark ? glassTintAlphaDark * 0.75 : glassTintAlphaLight) *
          enabledMul,
    );
    final Color activeBackground = colorScheme.primary.withValues(
      alpha: (isDark ? 0.22 : 0.18) * enabledMul,
    );
    final Color tintedBackground = tintColor != null
        ? Color.alphaBlend(
            tintColor!.withValues(alpha: (tintAlpha ?? 0.0) * enabledMul),
            baseBackground,
          )
        : baseBackground;
    final Color baseBorder = Colors.white.withValues(
      alpha:
          (isDark ? glassBorderAlphaDark * 0.78 : glassBorderAlphaLight) *
          enabledMul,
    );
    final Color activeBorder = colorScheme.primary.withValues(
      alpha: 0.85 * enabledMul,
    );
    final Color roleBorder = borderColor != null
        ? borderColor!.withValues(alpha: (borderAlpha ?? 1.0) * enabledMul)
        : baseBorder;

    final Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isActive ? activeBackground : tintedBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isActive ? activeBorder : roleBorder,
          width: isActive ? 1.5 : borderWidth,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(
                    alpha:
                        (isDark
                            ? glassShadowAlphaActiveDark
                            : glassShadowAlphaActiveLight) *
                        enabledMul,
                  ),
                  blurRadius: glassShadowBlurSm,
                  offset: const Offset(0, glassShadowOffsetYSm),
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
