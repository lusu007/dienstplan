import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
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
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: GlassScreenScaffold.kHeaderHeight,
      ),
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
            const SizedBox(width: glassSpacingXs),
            Expanded(
              child: Text(
                title,
                style: AppTypography.pageTitle(Theme.of(context)),
                softWrap: true,
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
    return AppGlassIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: AppLocalizations.of(context).back,
      onPressed: () => _handleBack(context),
      size: 40,
      iconSize: 22,
      shape: liquid.GlassIconButtonShape.roundedSquare,
      borderRadius: glassSurfaceRadiusMd + 2,
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
