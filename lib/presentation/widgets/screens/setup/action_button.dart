import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';

/// Primary/secondary action button used at the bottom of the setup flow.
///
/// Primary uses [GlassContainer] so it matches the calendar glass action bar.
/// Secondary uses the same frosted pill language as [SetupBackButton].
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final bool isPrimary;
  final Color? mainColor;
  final double height;
  final double fontSize;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.isPrimary = true,
    this.mainColor,
    this.height = 56,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accent = mainColor ?? colorScheme.primary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String effectiveLoadingText = loadingText ?? text;
    final bool tapEnabled = onPressed != null && !isLoading;
    final bool visuallyDimmed = onPressed == null && !isLoading;
    final double frameOpacity = visuallyDimmed ? 0.4 : 1.0;

    if (isPrimary) {
      // Frosted fill reads much lighter than solid primary; onPrimary is often
      // white and disappears on light glass. onSurface matches the surface
      // tone behind the blur and stays readable in both themes.
      final Color labelColor = colorScheme.onSurface;
      final Widget body = SizedBox(
        width: double.infinity,
        height: height,
        child: GlassContainer(
          borderRadius: 16,
          blurSigma: 20,
          tintOpacity: isDark ? 0.34 : 0.30,
          borderOpacity: isDark ? 0.30 : 0.42,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: tapEnabled ? onPressed : null,
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: labelColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    child: _buildButtonContent(
                      effectiveLoadingText,
                      indicatorColor: labelColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return Opacity(opacity: frameOpacity, child: body);
    }

    final Color foreground = colorScheme.onSurface;
    final Widget body = SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: tapEnabled ? onPressed : null,
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
                ),
                width: 1,
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: foreground,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              child: _buildButtonContent(
                effectiveLoadingText,
                indicatorColor: accent,
              ),
            ),
          ),
        ),
      ),
    );
    return Opacity(opacity: frameOpacity, child: body);
  }

  Widget _buildButtonContent(
    String buttonText, {
    required Color indicatorColor,
  }) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: indicatorColor,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(buttonText, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(buttonText);
  }
}
