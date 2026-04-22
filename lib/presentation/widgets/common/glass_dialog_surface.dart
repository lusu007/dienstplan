import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';

/// Frosted-glass surface used as the root container of glass-morphism dialogs.
///
/// Stacks two coloured ambient blobs behind a strong [BackdropFilter] and
/// layers a double border on top to emulate the edge of a glass pane. Used by
/// the schedules dialog, the month/year picker and any future glass modal.
class GlassDialogSurface extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry borderRadius;

  const GlassDialogSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tintColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.5)
        : colorScheme.surface.withValues(alpha: 0.38);
    final Color outerBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.5);
    final Color innerBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.28);
    final Color partnerAccent = const Color(
      AccentColorDefaults.partnerAccentColorValue,
    ).withValues(alpha: isDark ? 0.34 : 0.28);
    final Color primaryAccent = colorScheme.primary.withValues(
      alpha: isDark ? 0.42 : 0.32,
    );
    final BorderRadius innerBorderRadius = _shrinkBorderRadius(
      borderRadius,
      context,
      by: 1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.22),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              left: -80,
              top: -120,
              child: AmbientBlob(color: primaryAccent, diameter: 260),
            ),
            Positioned(
              right: -60,
              bottom: -80,
              child: AmbientBlob(color: partnerAccent, diameter: 220),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                decoration: BoxDecoration(color: tintColor),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: innerBorderRadius,
                      border: Border.all(color: innerBorderColor, width: 1),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(color: outerBorderColor, width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _shrinkBorderRadius(
    BorderRadiusGeometry geometry,
    BuildContext context, {
    required double by,
  }) {
    final BorderRadius resolved = geometry.resolve(Directionality.of(context));
    Radius shrink(Radius radius) {
      return Radius.elliptical(
        (radius.x - by).clamp(0.0, double.infinity),
        (radius.y - by).clamp(0.0, double.infinity),
      );
    }

    return BorderRadius.only(
      topLeft: shrink(resolved.topLeft),
      topRight: shrink(resolved.topRight),
      bottomLeft: shrink(resolved.bottomLeft),
      bottomRight: shrink(resolved.bottomRight),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: isDark ? 0.12 : 0.28),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Soft radial colour blob used behind the glass surface blur to create a
/// subtle ambient hue shift.
class AmbientBlob extends StatelessWidget {
  final Color color;
  final double diameter;

  const AmbientBlob({super.key, required this.color, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
