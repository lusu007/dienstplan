import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';

// Glass-adjacent calendar cell surfaces (no BackdropFilter per cell — tint + border only).

double calendarDayCellBorderRadius({required bool compact}) {
  return compact ? 8.0 : glassSurfaceRadiusSm;
}

/// Today cell fill only (no border). Border goes on [Container.foregroundDecoration]
/// so content is not inset and aligns with non-bordered cells (e.g. holiday stripe).
BoxDecoration calendarDayTodayCellFillDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required double borderRadius,
}) {
  final bool isDark = brightness == Brightness.dark;
  final double tint = isDark ? glassTintAlphaDark + 0.08 : glassTintAlphaLight;
  return BoxDecoration(
    color: colorScheme.primary.withValues(alpha: tint),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

/// Today cell border for [Container.foregroundDecoration] (pairs with fill decoration).
BoxDecoration calendarDayTodayCellBorderDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required double borderRadius,
}) {
  final bool isDark = brightness == Brightness.dark;
  final double borderAlpha = isDark
      ? glassBorderAlphaDark * 0.6
      : glassBorderAlphaLight;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: borderAlpha),
      width: 1,
    ),
  );
}

/// Selected cell fill only (no border). Border on [Container.foregroundDecoration].
BoxDecoration calendarDaySelectedCellFillDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required double borderRadius,
}) {
  final bool isDark = brightness == Brightness.dark;
  final double fillAlpha = isDark
      ? glassTintAlphaActiveDark + 0.08
      : glassTintAlphaActiveLight + 0.16;
  return BoxDecoration(
    color: colorScheme.primary.withValues(alpha: fillAlpha.clamp(0.0, 1.0)),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

/// Selected cell border for [Container.foregroundDecoration].
BoxDecoration calendarDaySelectedCellBorderDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required double borderRadius,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: colorScheme.primary.withValues(alpha: glassBorderAlphaActive),
      width: 1,
    ),
  );
}

Color calendarDayTodayDayNumberColor(ColorScheme colorScheme) {
  return colorScheme.primary;
}

/// Readable on the semi-transparent selected cell (not a solid primary fill).
Color calendarDaySelectedDayNumberColor(
  ColorScheme colorScheme,
  Brightness brightness,
) {
  return brightness == Brightness.light
      ? colorScheme.primary
      : colorScheme.onSurface;
}

/// Personal entry chip on selected day (replaces flat black overlay).
BoxDecoration calendarDayPersonalEntryDecorationSelected({
  required ColorScheme colorScheme,
  required Brightness brightness,
  required double borderRadius,
}) {
  final Color bg = brightness == Brightness.light
      ? colorScheme.primary.withValues(alpha: 0.2)
      : colorScheme.onSurface.withValues(alpha: 0.14);
  return BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

Color calendarDayPersonalEntryTextColorSelected(
  ColorScheme colorScheme,
  Brightness brightness,
) {
  return brightness == Brightness.light
      ? colorScheme.primary
      : colorScheme.onSurface;
}

/// Outline on duty/partner badges when the day cell is selected. High contrast
/// vs. the cell border (also primary-tinted) and vs. saturated accent fills.
Color calendarDayBadgeSelectedBorderColor(
  ColorScheme colorScheme,
  Brightness brightness,
) {
  return brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.92)
      : colorScheme.onSurface.withValues(alpha: 0.88);
}

/// Circular markers for [TableCalendar] when default decorations show through.
BoxDecoration calendarTableFallbackSelectedDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
}) {
  final bool isDark = brightness == Brightness.dark;
  final double fillAlpha = isDark
      ? glassTintAlphaActiveDark + 0.08
      : glassTintAlphaActiveLight + 0.16;
  return BoxDecoration(
    color: colorScheme.primary.withValues(alpha: fillAlpha.clamp(0.0, 1.0)),
    shape: BoxShape.circle,
    border: Border.all(
      color: colorScheme.primary.withValues(alpha: glassBorderAlphaActive),
      width: 1,
    ),
  );
}

BoxDecoration calendarTableFallbackTodayDecoration({
  required ColorScheme colorScheme,
  required Brightness brightness,
}) {
  final bool isDark = brightness == Brightness.dark;
  final double tint = isDark ? glassTintAlphaDark + 0.08 : glassTintAlphaLight;
  final double borderAlpha = isDark
      ? glassBorderAlphaDark * 0.6
      : glassBorderAlphaLight;
  return BoxDecoration(
    color: colorScheme.primary.withValues(alpha: tint),
    shape: BoxShape.circle,
    border: Border.all(
      color: Colors.white.withValues(alpha: borderAlpha),
      width: 1,
    ),
  );
}
