import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter/material.dart';

/// Transient feedback must remain readable above any underlying content.
abstract final class AppFeedbackStyle {
  static Color fill(ColorScheme scheme) =>
      scheme.surface.withValues(alpha: .96);
  static Color border(ColorScheme scheme) => scheme.onSurface.withValues(
    alpha: scheme.brightness == Brightness.dark ? .28 : .22,
  );
  static TextStyle text(ColorScheme scheme) => TextStyle(
    color: scheme.onSurface,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static SnackBarThemeData snackBar(ColorScheme scheme) => SnackBarThemeData(
    backgroundColor: fill(scheme),
    contentTextStyle: text(scheme),
    actionTextColor: scheme.onSurface,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: const EdgeInsets.fromLTRB(
      glassSpacingMd,
      0,
      glassSpacingMd,
      glassSpacingMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(glassSurfaceRadiusMd),
      side: BorderSide(color: border(scheme)),
    ),
  );
  static TooltipThemeData tooltip(ColorScheme scheme) => TooltipThemeData(
    textStyle: text(scheme),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: fill(scheme),
      borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
      border: Border.all(color: border(scheme)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
  );
}
