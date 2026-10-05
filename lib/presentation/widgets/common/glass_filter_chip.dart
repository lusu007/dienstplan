import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_chip_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:dienstplan/presentation/widgets/common/app_sheet_style.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class GlassFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckmark;

  /// When true, the glass pill expands to the parent's max width (e.g. inside
  /// [Expanded]). If horizontal constraints are unbounded (e.g. bare [Row]
  /// child), expansion is skipped and the label stays intrinsic-width centered.
  final bool expandWidth;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showCheckmark = false,
    this.expandWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color selectedTint = colorScheme.primary.withValues(
      alpha: isDark
          ? glassCardActiveTintAlphaDark
          : glassCardActiveTintAlphaLight,
    );
    final Color tint = isSelected
        ? selectedTint
        : colorScheme.primary.withValues(
            alpha: isDark
                ? kGlassFilterUnselectedTintAlphaDark
                : kGlassFilterUnselectedTintAlphaLight,
          );
    final Color textColor = colorScheme.onSurface;
    final TextStyle? labelBaseStyle = Theme.of(context).textTheme.labelLarge;
    final TextStyle labelStyle = (labelBaseStyle ?? const TextStyle()).copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.0,
    );
    final Widget chip = Semantics(
      selected: isSelected,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected
                  ? (isDark ? colorScheme.onSurface : colorScheme.primary)
                        .withValues(alpha: isDark ? 0.65 : 0.85)
                  : Colors.transparent,
              width: isSelected ? glassCardActiveBorderWidth : 0,
            ),
          ),
        ),
        child: liquid.GlassChip(
          label: label,
          onTap: onTap,
          selected: isSelected,
          // The library's selected overlay only covers its padded content,
          // leaving an inset edge at our minimum height. Tint the glass itself.
          selectedColor: Colors.transparent,
          icon: showCheckmark && isSelected
              ? Icon(Icons.check_rounded, size: 14, color: textColor)
              : null,
          labelStyle: labelStyle,
          settings: appGlassSettings(
            context,
            tint: tint,
          ).copyWith(bodyMode: liquid.GlassBodyMode.adaptive),
          useOwnLayer: true,
          stretch: 0,
          interactionScale: 1,
          anchorStretch: false,
          padding: const EdgeInsets.symmetric(
            horizontal: kGlassFilterChipHorizontalPadding,
            vertical: kGlassFilterChipVerticalPadding,
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: kGlassFilterChipHeight,
            minWidth: expandWidth && constraints.hasBoundedWidth
                ? constraints.maxWidth
                : 0,
          ),
          child: chip,
        );
      },
    );
  }
}

class GlassIconToggleChip extends StatelessWidget {
  final bool isSelected;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isEnabled;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;

  const GlassIconToggleChip({
    super.key,
    required this.isSelected,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.onTap,
    this.tooltip,
    this.isEnabled = true,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool lightModal = AppModalSurfaceScope.isLight(context);
    final Color background = isSelected
        ? colorScheme.primary.withValues(
            alpha: isDark
                ? kGlassChipSelectedTintAlphaDark
                : kGlassChipSelectedTintAlphaLight,
          )
        : (lightModal ? colorScheme.onSurface : Colors.white).withValues(
            alpha: isDark
                ? kGlassChipUnselectedTintAlphaDark
                : lightModal
                ? glassModalFillAlphaLight
                : kGlassChipUnselectedTintAlphaLight,
          );
    final Color borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: kGlassChipSelectedBorderAlpha)
        : (lightModal ? colorScheme.onSurface : Colors.white).withValues(
            alpha: isDark
                ? kGlassChipUnselectedBorderAlphaDark
                : lightModal
                ? glassModalBorderAlphaLight
                : kGlassChipUnselectedBorderAlphaLight,
          );
    final Color selectedPreferredColor =
        selectedIconColor ??
        colorScheme.onPrimary.withValues(
          alpha: kGlassChipSelectedContentFallbackAlpha,
        );
    final Color defaultSelectedIconColor = isDark
        ? _resolveReadableForeground(
            background: background,
            preferred: selectedPreferredColor,
          )
        : (selectedIconColor ?? colorScheme.onSurface);
    final Color defaultUnselectedIconColor = colorScheme.onSurfaceVariant
        .withValues(alpha: isEnabled ? 1.0 : kGlassChipDisabledContentAlpha);
    final Color iconColor = isSelected
        ? defaultSelectedIconColor
        : (unselectedIconColor ?? defaultUnselectedIconColor);
    return AppGlassIconButton(
      icon: isSelected ? selectedIcon : unselectedIcon,
      onPressed: isEnabled ? onTap : null,
      tooltip: tooltip ?? '',
      isSelected: isSelected,
      size: kGlassIconChipSize,
      iconSize: kGlassIconChipIconSize,
      shape: liquid.GlassIconButtonShape.roundedSquare,
      borderRadius: kGlassIconChipRadius,
      tintColor: background,
      borderColor: borderColor,
      foregroundColor: iconColor,
    );
  }
}

Color _resolveReadableForeground({
  required Color background,
  required Color preferred,
}) {
  final Color opaqueBackground = background.withValues(alpha: 1.0);
  final double preferredContrast = _contrastRatio(preferred, opaqueBackground);
  if (preferredContrast >= kGlassChipSelectedContentMinContrast) {
    return preferred;
  }
  final Color white = Colors.white.withValues(
    alpha: kGlassChipSelectedContentFallbackAlpha,
  );
  final Color black = Colors.black.withValues(
    alpha: kGlassChipSelectedContentFallbackAlpha,
  );
  final double whiteContrast = _contrastRatio(white, opaqueBackground);
  final double blackContrast = _contrastRatio(black, opaqueBackground);
  return whiteContrast >= blackContrast ? white : black;
}

double _contrastRatio(Color a, Color b) {
  final double l1 = a.computeLuminance();
  final double l2 = b.computeLuminance();
  final double lighter = l1 > l2 ? l1 : l2;
  final double darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}
