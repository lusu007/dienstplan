import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';

/// Shared modal material, rendered by liquid_glass_widgets.
class GlassDialogSurface extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;
  final double? backdropBlurSigma;

  const GlassDialogSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(glassSurfaceRadiusXl),
    ),
    this.backdropBlurSigma,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius.resolve(Directionality.of(context));
    return ClipRRect(
      borderRadius: radius,
      child: AppGlassSurface(
        borderRadius: radius.topLeft.x,
        blur: backdropBlurSigma ?? glassSurfaceBlurDialog,
        tint: scheme.surface.withValues(
          alpha: isDark ? glassDialogTintAlphaDark : glassDialogTintAlphaLight,
        ),
        child: child,
      ),
    );
  }
}

/// A soft horizontal gradient line used as a decorative divider inside glass
/// surfaces.
class SoftGradientDivider extends StatelessWidget {
  const SoftGradientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: glassSpacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(
              alpha: isDark ? glassDividerAlphaDark : glassDividerAlphaLight,
            ),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
