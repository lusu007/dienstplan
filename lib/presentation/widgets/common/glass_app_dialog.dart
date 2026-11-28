import 'package:material_ui/material_ui.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';

/// Glass-morphism replacement for [AlertDialog].
///
/// Uses [GlassDialogSurface] as the modal body and slides in from below
/// while delegating the glass material to the shared package adapter.
class GlassAppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool adaptToCompactHeight;

  const GlassAppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.adaptToCompactHeight = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    bool adaptToCompactHeight = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Fading the live glass/backdrop needs an intermediate texture on
        // every frame. Translate it only and keep the glass scale stable.
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation.drive(CurveTween(curve: Curves.easeInOutCubic))),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return GlassAppDialog(
          title: title,
          content: content,
          actions: actions,
          adaptToCompactHeight: adaptToCompactHeight,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final availableHeight =
        media.size.height - media.padding.vertical - media.viewInsets.vertical;
    if (adaptToCompactHeight && availableHeight < 480) {
      // On short windows the title scrolls with the body, leaving both actions
      // reachable even with system insets and accessibility text scaling.
      return Material(
        color: colorScheme.surface,
        child: SafeArea(
          minimum: const EdgeInsets.all(glassSpacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: glassSpacingMd),
                      DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        child: content,
                      ),
                    ],
                  ),
                ),
              ),
              ...?actions,
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          glassSpacingXl,
          media.padding.top + glassSpacingXxl,
          glassSpacingXl,
          media.padding.bottom + glassSpacingXxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassDialogSurface(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  glassSpacingXl,
                  glassSpacingXl - 2,
                  glassSpacingXl,
                  glassSpacingLg + 2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: glassSpacingMd + 2),
                    Flexible(
                      child: DefaultTextStyle.merge(
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        child: content,
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: glassSpacingLg + glassSpacingXs),
                      ...actions!.map(
                        (Widget action) => Padding(
                          padding: const EdgeInsets.only(
                            top: glassSpacingXs + 2,
                          ),
                          child: action,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
