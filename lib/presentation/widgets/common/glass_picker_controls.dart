import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_picker_tokens.dart';

class GlassPickerPillTrigger extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const GlassPickerPillTrigger({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.expand_more_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kGlassPickerTriggerRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kGlassPickerTriggerRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: kGlassPickerTriggerBlur,
              sigmaY: kGlassPickerTriggerBlur,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                kGlassPickerTriggerPaddingHorizontal,
                kGlassPickerTriggerPaddingVertical,
                kGlassPickerTriggerTrailingPadding,
                kGlassPickerTriggerPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: isDark
                      ? kGlassPickerSurfaceAlphaDark
                      : kGlassPickerSurfaceAlphaLight,
                ),
                borderRadius: BorderRadius.circular(kGlassPickerTriggerRadius),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: isDark
                        ? kGlassPickerSurfaceBorderAlphaDark
                        : kGlassPickerSurfaceBorderAlphaLight,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: kGlassPickerTriggerLabelFontSize,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    icon,
                    color: foreground,
                    size: kGlassPickerTriggerIconSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassPickerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const GlassPickerIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final bool isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(kGlassPickerIconButtonRadius),
        child: Container(
          width: kGlassPickerIconButtonSize,
          height: kGlassPickerIconButtonSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: isDark
                  ? kGlassPickerSurfaceAlphaDark
                  : kGlassPickerSurfaceAlphaLight,
            ),
            borderRadius: BorderRadius.circular(kGlassPickerIconButtonRadius),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: isDark
                    ? kGlassPickerSurfaceBorderAlphaDark
                    : kGlassPickerSurfaceBorderAlphaLight,
              ),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: foreground.withValues(alpha: isEnabled ? 1.0 : 0.35),
            size: kGlassPickerIconSize,
          ),
        ),
      ),
    );
  }
}

class GlassPickerTile extends StatelessWidget {
  final String label;
  final bool isFocused;
  final bool isCurrent;
  final bool isEnabled;
  final VoidCallback? onTap;

  const GlassPickerTile({
    super.key,
    required this.label,
    required this.isFocused,
    required this.isCurrent,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = colorScheme.primary;
    Color background;
    Color borderColor;
    Color textColor;
    FontWeight fontWeight;
    List<BoxShadow> boxShadow = const <BoxShadow>[];
    if (!isEnabled) {
      background = Colors.white.withValues(alpha: isDark ? 0.02 : 0.08);
      borderColor = Colors.white.withValues(alpha: isDark ? 0.06 : 0.18);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
      fontWeight = FontWeight.w500;
    } else if (isFocused) {
      background = primary.withValues(alpha: isDark ? 0.45 : 0.38);
      borderColor = Colors.white.withValues(alpha: isDark ? 0.28 : 0.55);
      textColor = colorScheme.onPrimary;
      fontWeight = FontWeight.w700;
      boxShadow = <BoxShadow>[
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.35 : 0.28),
          blurRadius: kGlassPickerTileFocusedShadowBlur,
          offset: const Offset(0, kGlassPickerTileFocusedShadowOffsetY),
        ),
      ];
    } else if (isCurrent) {
      background = primary.withValues(alpha: isDark ? 0.2 : 0.16);
      borderColor = primary.withValues(alpha: 0.55);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w700;
    } else {
      background = Colors.white.withValues(alpha: isDark ? 0.06 : 0.2);
      borderColor = Colors.white.withValues(alpha: isDark ? 0.14 : 0.35);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w600;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kGlassPickerTileRadius),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(kGlassPickerTileRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: boxShadow,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
