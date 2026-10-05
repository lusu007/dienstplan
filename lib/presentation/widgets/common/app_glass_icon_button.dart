import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

/// A compact library icon surface inside a complete, accessible touch target.
class AppGlassIconButton extends StatelessWidget {
  const AppGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 48,
    this.iconSize = 22,
    this.isSelected = false,
    this.foregroundColor,
    this.tintColor,
    this.borderColor,
    this.shape = liquid.GlassIconButtonShape.circle,
    this.borderRadius = 16,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size, iconSize, borderRadius;
  final bool isSelected;
  final Color? foregroundColor, tintColor, borderColor;
  final liquid.GlassIconButtonShape shape;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightModal = AppModalSurfaceScope.isLight(context);
    final tint =
        tintColor ??
        (isDark || isSelected
                ? scheme.primary
                : lightModal
                ? scheme.onSurface
                : scheme.surface)
            .withValues(
              alpha: isSelected
                  ? (isDark
                        ? glassTintAlphaActiveDark
                        : glassTintAlphaActiveLight)
                  : (isDark
                        ? glassTintAlphaDark
                        : lightModal
                        ? glassModalFillAlphaLight
                        : glassTintAlphaLight),
            );
    final outline =
        borderColor ??
        (isDark || isSelected ? scheme.primary : scheme.onSurface).withValues(
          alpha: isDark
              ? glassBorderAlphaDark
              : isSelected
              ? glassBorderAlphaLight
              : lightModal
              ? glassModalBorderAlphaLight
              : glassControlBorderAlphaLight,
        );
    final native = liquid.GlassTheme(
      // GlassIconButton exposes its stretch configuration through the theme.
      // Scope this override to this control, keeping chips/sheets unchanged.
      data: liquid.GlassThemeData.of(context).copyWith(
        interaction: liquid.GlassInteractionSettings(
          stretch:
              onPressed == null ||
                  liquid.GlassAccessibilityData.of(context).reduceMotion
              ? 0
              : .4,
        ),
      ),
      child: liquid.GlassIconButton(
        icon: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: ShapeDecoration(
              shape: shape == liquid.GlassIconButtonShape.circle
                  ? CircleBorder(side: BorderSide(color: outline))
                  : liquid.LiquidRoundedRectangle(
                      borderRadius: borderRadius,
                      side: BorderSide(color: outline),
                    ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: foregroundColor ?? scheme.onSurface,
                size: iconSize,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        size: size,
        iconSize: iconSize,
        shape: shape,
        borderRadius: borderRadius,
        semanticLabel: tooltip,
        settings: appGlassSettings(context, tint: tint),
        useOwnLayer: true,
        interactionScale: 1,
        anchorStretch: true,
        anchorStretchSettings: appGlassAnchorStretch,
      ),
    );
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        selected: isSelected,
        label: tooltip,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(widthFactor: 1, heightFactor: 1, child: native),
            ),
          ),
        ),
      ),
    );
  }
}
