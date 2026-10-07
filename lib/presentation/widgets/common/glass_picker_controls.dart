import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_picker_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';

/// Keeps adjacent picker controls aligned, including with larger system text.
double glassPickerTriggerHeight(BuildContext context) {
  final painter = TextPainter(
    text: TextSpan(
      text: 'Mg',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: kGlassPickerTriggerLabelFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final height = painter.height + 2 * kGlassPickerTriggerPaddingVertical;
  painter.dispose();
  return height < 48 ? 48 : height;
}

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
    return GlassButtonSurface(
      onTap: onTap,
      enabled: true,
      height: null,
      borderRadius: kGlassPickerTriggerRadius,
      tintOpacity: isDark
          ? kGlassPickerSurfaceAlphaDark
          : kGlassPickerSurfaceAlphaLight,
      borderOpacity: isDark
          ? kGlassPickerSurfaceBorderAlphaDark
          : glassControlBorderAlphaLight,
      padding: const EdgeInsets.fromLTRB(
        kGlassPickerTriggerPaddingHorizontal,
        kGlassPickerTriggerPaddingVertical,
        kGlassPickerTriggerTrailingPadding,
        kGlassPickerTriggerPaddingVertical,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: kGlassPickerTriggerLabelFontSize,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: foreground, size: kGlassPickerTriggerIconSize),
          ],
        ),
      ),
    );
  }
}

class GlassPickerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;

  const GlassPickerIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = kGlassPickerIconButtonSize,
    this.borderRadius = kGlassPickerIconButtonRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassIconButton(
      icon: icon,
      onPressed: onPressed,
      size: size,
      iconSize: kGlassPickerIconSize,
      shape: borderRadius >= size / 2
          ? liquid.GlassIconButtonShape.circle
          : liquid.GlassIconButtonShape.roundedSquare,
      borderRadius: borderRadius,
      tooltip: icon == Icons.chevron_left_rounded
          ? MaterialLocalizations.of(context).backButtonTooltip
          : icon == Icons.chevron_right_rounded
          ? AppLocalizations.of(context).continueButton
          : AppLocalizations.of(context).today,
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
    if (!isEnabled) {
      background = Colors.white.withValues(alpha: isDark ? 0.02 : 0.08);
      borderColor = Colors.white.withValues(alpha: isDark ? 0.06 : 0.18);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
      fontWeight = FontWeight.w500;
    } else if (isFocused) {
      background = primary.withValues(alpha: isDark ? 0.45 : 0.38);
      borderColor = Colors.white.withValues(alpha: isDark ? 0.28 : 0.55);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w700;
    } else if (isCurrent) {
      background = primary.withValues(alpha: isDark ? 0.2 : 0.16);
      borderColor = primary.withValues(alpha: 0.55);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w700;
    } else {
      final lightModal = AppModalSurfaceScope.isLight(context);
      background = lightModal
          ? colorScheme.onSurface.withValues(alpha: glassModalFillAlphaLight)
          : Colors.white.withValues(alpha: isDark ? 0.06 : 0.2);
      borderColor = lightModal
          ? colorScheme.onSurface.withValues(alpha: glassModalBorderAlphaLight)
          : Colors.white.withValues(alpha: isDark ? 0.14 : 0.35);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w600;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kGlassPickerTileRadius),
        child: AppGlassSurface(
          refractive: false,
          tint: background,
          borderRadius: kGlassPickerTileRadius,
          borderColor: borderColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final style = Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: fontWeight, color: textColor);
              final labelWidget = Text(label, style: style);
              if (isDark || !isFocused) {
                return Center(child: labelWidget);
              }
              final painter = TextPainter(
                text: TextSpan(text: label, style: style),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout();
              final needsVerticalMarker =
                  painter.width + 18 > constraints.maxWidth;
              painter.dispose();
              return Center(
                child: needsVerticalMarker
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 10, color: textColor),
                          const SizedBox(height: 2),
                          labelWidget,
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 14, color: textColor),
                          const SizedBox(width: 4),
                          labelWidget,
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
