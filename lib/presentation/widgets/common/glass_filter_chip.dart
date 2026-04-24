import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_chip_tokens.dart';

class GlassFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckmark;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background = isSelected
        ? colorScheme.primary.withValues(
            alpha: isDark
                ? kGlassChipSelectedTintAlphaDark
                : kGlassChipSelectedTintAlphaLight,
          )
        : Colors.white.withValues(
            alpha: isDark
                ? kGlassChipUnselectedTintAlphaDark
                : kGlassChipUnselectedTintAlphaLight,
          );
    final Color borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: kGlassChipSelectedBorderAlpha)
        : Colors.white.withValues(
            alpha: isDark
                ? kGlassChipUnselectedBorderAlphaDark
                : kGlassChipUnselectedBorderAlphaLight,
          );
    final Color selectedContentColor = _resolveReadableForeground(
      background: background,
      preferred: colorScheme.onPrimary.withValues(
        alpha: kGlassChipSelectedContentFallbackAlpha,
      ),
    );
    final Color textColor = isSelected
        ? selectedContentColor
        : colorScheme.primary;
    final Color splashColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.18 : 0.12,
    );
    final Color hoverColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.12 : 0.08,
    );
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: borderColor, width: kGlassChipBorderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        splashColor: splashColor,
        highlightColor: Colors.transparent,
        hoverColor: hoverColor,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: kGlassChipHorizontalPadding,
            vertical: kGlassChipVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(kGlassChipRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheckmark && isSelected) ...[
                Icon(Icons.check_rounded, size: 14, color: textColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  height: 1.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final Color background = isSelected
        ? colorScheme.primary.withValues(
            alpha: isDark
                ? kGlassChipSelectedTintAlphaDark
                : kGlassChipSelectedTintAlphaLight,
          )
        : Colors.white.withValues(
            alpha: isDark
                ? kGlassChipUnselectedTintAlphaDark
                : kGlassChipUnselectedTintAlphaLight,
          );
    final Color borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: kGlassChipSelectedBorderAlpha)
        : Colors.white.withValues(
            alpha: isDark
                ? kGlassChipUnselectedBorderAlphaDark
                : kGlassChipUnselectedBorderAlphaLight,
          );
    final Color selectedPreferredColor =
        selectedIconColor ??
        colorScheme.onPrimary.withValues(
          alpha: kGlassChipSelectedContentFallbackAlpha,
        );
    final Color defaultSelectedIconColor = _resolveReadableForeground(
      background: background,
      preferred: selectedPreferredColor,
    );
    final Color defaultUnselectedIconColor = colorScheme.onSurfaceVariant
        .withValues(alpha: isEnabled ? 1.0 : kGlassChipDisabledContentAlpha);
    final Color iconColor = isSelected
        ? defaultSelectedIconColor
        : (unselectedIconColor ?? defaultUnselectedIconColor);
    final Widget chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(kGlassIconChipRadius),
        child: Container(
          width: kGlassIconChipSize,
          height: kGlassIconChipSize,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(kGlassIconChipRadius),
            border: Border.all(
              color: borderColor,
              width: kGlassChipBorderWidth,
            ),
          ),
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            size: kGlassIconChipIconSize,
            color: iconColor,
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) {
      return chip;
    }
    return Tooltip(message: tooltip!, child: chip);
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
