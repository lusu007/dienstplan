import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/ambient_blob.dart';

/// Reusable glass-morphism container using [BackdropFilter] with a blurred,
/// semi-transparent tint derived from the current color scheme.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = glassSurfaceRadiusLg,
    this.blurSigma = glassSurfaceBlurDefault,
    this.tintOpacity = 0.22,
    this.borderOpacity = 0.25,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tintColor = isDark
        ? colorScheme.primary.withValues(alpha: tintOpacity + 0.08)
        : colorScheme.primary.withValues(alpha: tintOpacity);
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity * 0.6)
        : Colors.white.withValues(alpha: borderOpacity);

    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? glassShadowAlphaDark : glassShadowAlphaLight,
                ),
                blurRadius: glassShadowBlurMd,
                offset: const Offset(0, glassShadowOffsetYSm),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin == null) {
      return content;
    }
    return Padding(padding: margin!, child: content);
  }
}

/// Ambient "aurora" background used beneath the glass layers so the blur is
/// actually visible over the scaffold.
///
/// Renders a top-to-bottom tinted gradient as base layer and three statically
/// positioned primary-tint blobs on top. The blobs use radial gradients with
/// transparent edges so they dissolve softly into the base gradient.
class CalendarBackdrop extends StatelessWidget {
  final Widget child;

  const CalendarBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  colorScheme.surface,
                  Color.alphaBlend(
                    colorScheme.primary.withValues(alpha: 0.14),
                    colorScheme.surface,
                  ),
                ]
              : [
                  colorScheme.surface,
                  Color.alphaBlend(
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.surface,
                  ),
                ],
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final Color primary = colorScheme.primary;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -80,
                right: -100,
                child: AmbientBlob(
                  color: primary.withValues(alpha: isDark ? 0.42 : 0.32),
                  diameter: 320,
                ),
              ),
              Positioned(
                bottom: 40,
                left: -120,
                child: AmbientBlob(
                  color: primary.withValues(alpha: isDark ? 0.28 : 0.20),
                  diameter: 280,
                ),
              ),
              Positioned(
                top: height * 0.42,
                left: width * 0.35,
                child: AmbientBlob(
                  color: primary.withValues(alpha: isDark ? 0.16 : 0.10),
                  diameter: 420,
                ),
              ),
              child,
            ],
          );
        },
      ),
    );
  }
}
