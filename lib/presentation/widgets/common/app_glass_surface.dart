import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

/// Package-backed surface shared by the app's existing glass adapters.
/// Content cards and nested surfaces use the package's non-refractive fill.
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.tint,
    this.borderColor,
    this.borderWidth = 1,
    this.blur,
    this.padding,
    this.refractive = true,
  });

  final Widget child;
  final double borderRadius;
  final Color tint;
  final Color? borderColor;
  final double borderWidth;
  final double? blur;
  final EdgeInsetsGeometry? padding;
  final bool refractive;

  @override
  Widget build(BuildContext context) {
    final settings = appGlassSettings(context, tint: tint, blur: blur);
    final shape = liquid.LiquidRoundedSuperellipse(borderRadius: borderRadius);
    final bool nested =
        context
            .dependOnInheritedWidgetOfExactType<liquid.InheritedLiquidGlass>()
            ?.avoidsRefraction ??
        false;
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    final Widget surface;
    if (!refractive || nested) {
      surface = liquid.AdaptiveGlass.vibrancy(
        shape: shape,
        // Our foreground border already defines this surface's outline. The
        // library's overlay-blended rim changes contrast when Android stretch
        // composites the scroll content into an intermediate texture.
        settings: borderColor == null
            ? settings
            : settings.copyWith(lightIntensity: 0),
        child: content,
      );
    } else {
      surface = liquid.GlassContainer(
        shape: shape,
        settings: settings,
        useOwnLayer: true,
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(
        shape: liquid.LiquidRoundedSuperellipse(
          borderRadius: borderRadius,
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!, width: borderWidth),
        ),
      ),
      child: surface,
    );
  }
}
