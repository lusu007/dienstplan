import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class GlassButtonSurface extends StatelessWidget {
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
    final Color tint =
        tintColor ??
        scheme.primary.withValues(
          alpha:
              tintOpacity ??
              (isDark ? glassTintAlphaDark : glassTintAlphaLight),
        );
    final Color outline =
        borderColor ??
        scheme.primary.withValues(
          alpha:
              borderOpacity ??
              (isDark ? glassBorderAlphaDark : glassBorderAlphaLight),
        );
    final bool interactive = enabled && onTap != null;
    final Widget sized;
    if (interactive) {
      // Standard-quality shaders do not paint LiquidShape.side. Paint the
      // app's semantic outline once, above either the shader or vibrancy fill.
      sized = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: liquid.LiquidRoundedSuperellipse(
            borderRadius: borderRadius,
            side: BorderSide(color: outline),
          ),
        ),
        child: liquid.GlassButton.custom(
          onTap: onTap!,
          width: fullWidth ? double.infinity : width,
          height: height,
          shape: liquid.LiquidRoundedSuperellipse(borderRadius: borderRadius),
          settings: appGlassSettings(context, tint: tint),
          useOwnLayer: true,
          stretch: 0,
          interactionScale: 1,
          anchorStretch: false,
          alignment: alignment,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
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
          child: AppGlassSurface(
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
