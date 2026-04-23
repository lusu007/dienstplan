import 'package:flutter/material.dart';

/// Glass-styled back button used inside the setup flow.
///
/// Matches the back-button in `GlassScreenScaffold` so the setup header feels
/// consistent with the rest of the glass UI.
class SetupBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  /// Unused tint override - kept for backwards compatibility with existing
  /// call sites that still pass `mainColor`. The button now derives its
  /// foreground from the theme.
  final Color? mainColor;
  final double size;

  const SetupBackButton({
    super.key,
    this.onPressed,
    this.mainColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final bool enabled = onPressed != null;
    final double opacity = enabled ? 1.0 : 0.45;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: (isDark ? 0.08 : 0.28) * opacity,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: (isDark ? 0.18 : 0.45) * opacity,
                ),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 24,
              color: foreground.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}
