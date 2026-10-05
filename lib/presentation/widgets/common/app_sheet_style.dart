import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';

/// Restricts the inner Light material recipe to modal content.
class AppModalSurfaceScope extends InheritedWidget {
  const AppModalSurfaceScope({super.key, required super.child});

  static bool isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light &&
      context.dependOnInheritedWidgetOfExactType<AppModalSurfaceScope>() !=
          null;

  @override
  bool updateShouldNotify(AppModalSurfaceScope oldWidget) => false;
}

/// Light shell rules. Dark keeps the existing geometry and white handle.
abstract final class AppSheetStyle {
  static double radius(bool isDark) =>
      isDark ? glassSurfaceRadiusLg + glassSpacingSm / 2 : glassSurfaceRadiusXl;
  static EdgeInsets margin(BuildContext context) => EdgeInsets.fromLTRB(
    glassSpacingSm,
    0,
    glassSpacingSm,
    glassSpacingSm +
        (Theme.of(context).brightness == Brightness.light
            ? MediaQuery.paddingOf(context).bottom
            : 0),
  );
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      button: true,
      onTap: () => Navigator.maybePop(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: isDark ? glassDragHandleTopGap : glassSpacingLg,
        ),
        child: Center(
          child: Container(
            width: glassDragHandleWidth,
            height: glassDragHandleHeight,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: glassDragHandleAlphaDark)
                  : theme.colorScheme.onSurface.withValues(
                      alpha: glassModalHandleAlphaLight,
                    ),
              borderRadius: BorderRadius.circular(glassSpacingXs / 2),
            ),
          ),
        ),
      ),
    );
  }
}
