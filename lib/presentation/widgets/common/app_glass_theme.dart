import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

/// The one app-level entry point for package theming and accessibility.
class AppGlassTheme extends StatelessWidget {
  const AppGlassTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return liquid.LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      theme: const liquid.GlassThemeData(
        light: liquid.GlassThemeVariant(
          quality: liquid.GlassQuality.standard,
          settings: liquid.GlassThemeSettings(
            blur: glassSurfaceBlurDefault,
            thickness: 30,
          ),
        ),
        dark: liquid.GlassThemeVariant(
          quality: liquid.GlassQuality.standard,
          settings: liquid.GlassThemeSettings(
            blur: glassSurfaceBlurDefault,
            thickness: 30,
          ),
        ),
      ),
      child: child,
    );
  }
}

liquid.LiquidGlassSettings appGlassSettings(
  BuildContext context, {
  Color? tint,
  double? blur,
}) {
  final overrides = liquid.GlassThemeData.of(
    context,
  ).variantFor(context).settings;
  final base =
      overrides?.applyTo(const liquid.LiquidGlassSettings()) ??
      const liquid.LiquidGlassSettings();
  return base.copyWith(
    glassColor: tint,
    blur: blur,
    // Preserve semantic app tints instead of adapting their hue to the backdrop.
    bodyMode: liquid.GlassBodyMode.clear,
  );
}
