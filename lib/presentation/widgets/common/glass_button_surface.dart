import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';

class GlassButtonSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final double height;
  final bool fullWidth;
  final double? width;
  final double opacity;
  final AlignmentGeometry alignment;

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
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Widget content = GlassContainer(
      borderRadius: borderRadius,
      blurSigma: glassSurfaceBlurDefault,
      tintOpacity: isDark ? glassTintAlphaDark : glassTintAlphaLight,
      borderOpacity: isDark ? glassBorderAlphaDark : glassBorderAlphaLight,
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Align(alignment: alignment, child: child),
        ),
      ),
    );
    final Widget sized = SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: content,
    );
    if (opacity == 1.0) {
      return sized;
    }
    return Opacity(opacity: opacity, child: sized);
  }
}
