import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class GlassButtonSurface extends StatelessWidget {
  final liquid.GlassButtonStyle style;
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final double? height;
  final bool fullWidth;
  final double? width;
  final double opacity;
  final AlignmentGeometry alignment;
  final Color? tintColor;
  final Color? borderColor;
  final double? tintOpacity;
  final double? borderOpacity;

  const GlassButtonSurface({
    super.key,
    this.style = liquid.GlassButtonStyle.filled,
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.padding,
    required this.enabled,
    required this.height,
    this.fullWidth = false,
    this.width,
    this.opacity = 1.0,
    this.alignment = Alignment.center,
    this.tintColor,
    this.borderColor,
    this.tintOpacity,
    this.borderOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final lightModal = AppModalSurfaceScope.isLight(context);
    final Color tint =
        tintColor ??
        (isDark
                ? scheme.primary
                : lightModal
                ? scheme.onSurface
                : scheme.surface)
            .withValues(
              alpha:
                  (lightModal ? glassModalFillAlphaLight : tintOpacity) ??
                  (isDark ? glassTintAlphaDark : glassTintAlphaLight),
            );
    final Color outline =
        borderColor ??
        (isDark ? scheme.primary : scheme.onSurface).withValues(
          alpha:
              (lightModal ? glassModalBorderAlphaLight : borderOpacity) ??
              (isDark ? glassBorderAlphaDark : glassControlBorderAlphaLight),
        );
    final bool interactive = enabled && onTap != null;
    final Widget sized;
    if (interactive) {
      // Paint the semantic outline inside the library's animated content so
      // it deforms together with the glass, including standard shader quality.
      sized = LayoutBuilder(
        builder: (context, constraints) => liquid.GlassButton.custom(
          onTap: onTap!,
          style: style,
          shape: liquid.LiquidRoundedSuperellipse(borderRadius: borderRadius),
          settings: appGlassSettings(context, tint: tint),
          useOwnLayer: true,
          stretch: liquid.GlassAccessibilityData.of(context).reduceMotion
              ? 0
              : .4,
          interactionScale: 1,
          anchorStretch: true,
          anchorStretchSettings: appGlassAnchorStretch,
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.minWidth,
              minHeight: constraints.minHeight,
            ),
            child: SizedBox(
              width: fullWidth ? double.infinity : width,
              height: height,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: ShapeDecoration(
                  shape: liquid.LiquidRoundedSuperellipse(
                    borderRadius: borderRadius,
                    side: BorderSide(color: outline),
                  ),
                ),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    alignment: alignment,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // The library's disabled button always halves opacity. Here appearance
      // belongs to the caller (especially fully visible loading indicators),
      // so use its passive material with no pointer/keyboard activation.
      sized = Semantics(
        button: true,
        enabled: false,
        child: SizedBox(
          width: fullWidth ? double.infinity : width,
          height: height,
          child: style == liquid.GlassButtonStyle.transparent
              ? Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    alignment: alignment,
                    child: child,
                  ),
                )
              : AppGlassSurface(
                  borderRadius: borderRadius,
                  tint: tint,
                  borderColor: outline,
                  padding: padding,
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    alignment: alignment,
                    child: child,
                  ),
                ),
        ),
      );
    }
    if (opacity == 1.0) {
      return sized;
    }
    return Opacity(opacity: opacity, child: sized);
  }
}
