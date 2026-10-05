import 'package:flutter/material.dart';

/// Shared text roles; apply equally in Light and Dark without changing palettes.
abstract final class AppTypography {
  static const actionSize = 16.0;
  static TextStyle action(ThemeData theme) => theme.textTheme.labelLarge!
      .copyWith(fontSize: actionSize, fontWeight: FontWeight.w700);
  static TextStyle menuTitle(ThemeData theme) =>
      theme.textTheme.titleMedium!.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      );
  static TextStyle secondary(ThemeData theme) => theme.textTheme.bodyMedium!
      .copyWith(fontSize: 14, color: theme.colorScheme.onSurfaceVariant);
  static TextStyle pageTitle(ThemeData theme) =>
      theme.textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: .2,
        height: 1.1,
        color: theme.colorScheme.onSurface,
      );
  static TextStyle sheetTitle(ThemeData theme) =>
      theme.textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      );
}
