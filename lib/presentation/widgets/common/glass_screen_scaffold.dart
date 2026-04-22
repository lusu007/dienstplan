import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const GlassScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
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
                Expanded(child: ScrollFadeMask(child: child)),
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
    return SizedBox(
      height: GlassScreenScaffold.kHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _GlassBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actions != null) ...[
              const SizedBox(width: 8),
              ...actions!.expand((Widget a) sync* {
                yield a;
                yield const SizedBox(width: 4);
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _handleBack(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
              width: 1,
            ),
          ),
          child: Icon(Icons.arrow_back_rounded, color: foreground, size: 22),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
