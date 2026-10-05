import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

enum AppGlassButtonRole { primary, secondary, quiet, destructive }

/// Semantic actions backed by the installed glass library. Sizes are minima:
/// labels can wrap when accessibility text scaling needs additional space.
class AppGlassButton extends StatelessWidget {
  const AppGlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.role = AppGlassButtonRole.secondary,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = false,
    this.height,
    this.compact = false,
    this.width,
    this.fontSize = AppTypography.actionSize,
    this.borderRadius = glassSurfaceRadiusSm,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });
  factory AppGlassButton.icon({
    Key? key,
    required Widget icon,
    required Widget label,
    required VoidCallback? onPressed,
    AppGlassButtonRole role = AppGlassButtonRole.secondary,
    bool isLoading = false,
    bool enabled = true,
    bool fullWidth = false,
    double? height,
  }) => AppGlassButton(
    key: key,
    onPressed: onPressed,
    role: role,
    isLoading: isLoading,
    enabled: enabled,
    fullWidth: fullWidth,
    height: height,
    child: isLoading
        ? label
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(child: label),
            ],
          ),
  );

  final Widget child;
  final VoidCallback? onPressed;
  final AppGlassButtonRole role;
  final bool isLoading, enabled, fullWidth;

  /// A smaller visual surface within the same 48dp touch target.
  final bool compact;
  final double? height, width;
  final double fontSize, borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = enabled && onPressed != null && !isLoading;
    final danger = role == AppGlassButtonRole.destructive;
    final primary = role == AppGlassButtonRole.primary;
    final quiet = role == AppGlassButtonRole.quiet;
    final lightModal = AppModalSurfaceScope.isLight(context);
    final tint =
        (danger
                ? scheme.error
                : !isDark && !primary
                ? (lightModal ? scheme.onSurface : scheme.surface)
                : scheme.primary)
            .withValues(
              alpha: quiet
                  ? 0
                  : primary
                  ? (isDark ? 0.20 : 0.28)
                  : (isDark
                        ? glassTintAlphaDark
                        : lightModal && !danger
                        ? glassModalFillAlphaLight
                        : glassTintAlphaLight),
            );
    final foreground = danger
        ? (isDark ? scheme.error : scheme.onErrorContainer)
        : scheme.onSurface;
    final outline =
        (danger
                ? scheme.error
                : !isDark && !primary
                ? scheme.onSurface
                : scheme.primary)
            .withValues(
              alpha: quiet
                  ? 0
                  : primary && isDark
                  ? 0.30
                  : (isDark
                        ? glassBorderAlphaDark
                        : !primary && !danger
                        ? (lightModal
                              ? glassModalBorderAlphaLight
                              : glassControlBorderAlphaLight)
                        : glassBorderAlphaLight),
            );
    final style = primary
        ? liquid.GlassButtonStyle.prominent
        : quiet
        ? liquid.GlassButtonStyle.transparent
        : liquid.GlassButtonStyle.filled;
    final content = DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: foreground,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: 20),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: child),
                ],
              )
            : child,
      ),
    );
    final minimumHeight = compact ? 36.0 : 48.0;
    final surface = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height == null || height! < minimumHeight
            ? minimumHeight
            : height!,
        minWidth: 48,
      ),
      child: GlassButtonSurface(
        style: style,
        onTap: active ? onPressed : null,
        enabled: active,
        borderRadius: borderRadius,
        height: null,
        width: width,
        fullWidth: fullWidth,
        tintColor: tint,
        borderColor: outline,
        padding: padding,
        opacity: !active && !isLoading ? 0.45 : 1,
        child: content,
      ),
    );
    if (!compact) return surface;
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: active ? onPressed : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(widthFactor: 1, heightFactor: 1, child: surface),
        ),
      ),
    );
  }
}
