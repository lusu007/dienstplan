import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:flutter/services.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';

/// Glass-morphism scaffold used by the settings screen and its sub-screens.
///
/// Renders the [CalendarBackdrop] aurora as page background, overlays a
/// custom [_GlassScreenHeader] with a glass back-button and title, and hosts
/// the provided [child] below it. Status-bar icons adapt automatically to
/// the current brightness.
class GlassScreenScaffold extends StatelessWidget {
  static const double kHeaderHeight = 56.0;

  final String title;
  final Widget child;
  final List<Widget>? actions;

  /// Optional edge fade. Off by default: masking scrollable glass groups can
  /// hide their contents on Android/Impeller (reproduced on the S22 Ultra).
  /// Keep disabled for platform views as well.
  final bool fadeScrollEdges;

  const GlassScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.fadeScrollEdges = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: CalendarBackdrop(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GlassScreenHeader(title: title, actions: actions),
                Expanded(
                  child: fadeScrollEdges ? ScrollFadeMask(child: child) : child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassScreenHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const _GlassScreenHeader({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final TextStyle? baseStyle = Theme.of(context).textTheme.titleLarge;
    return SizedBox(
      height: GlassScreenScaffold.kHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingMd,
          glassSpacingXs,
          glassSpacingMd,
          glassSpacingXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _GlassBackButton(),
            const SizedBox(width: glassSpacingMd),
            Expanded(
              child: Text(
                title,
                style: (baseStyle ?? const TextStyle()).copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: glassSpacingSm),
              ...actions!.expand((Widget a) sync* {
                yield a;
                yield const SizedBox(width: glassSpacingXs);
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.back,
      child: GlassButtonSurface(
        onTap: () => _handleBack(context),
        enabled: true,
        width: 40,
        height: 40,
        borderRadius: glassSurfaceRadiusMd + 2,
        tintOpacity: isDark ? glassTintAlphaDark : glassTintAlphaLight,
        borderOpacity: isDark ? glassBorderAlphaDark : glassBorderAlphaLight,
        child: Icon(Icons.arrow_back_rounded, color: foreground, size: 22),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
