import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';

/// Glass-morphism replacement for [AlertDialog].
///
/// Uses [GlassDialogSurface] as the modal body, fades + slides in from below
/// with the same animation as the schedules dialog, and adds a subtle
/// backdrop blur behind the barrier so the page content dissolves while the
/// dialog is open.
class GlassAppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const GlassAppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            FadeTransition(
              opacity: curved,
              child: IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return GlassAppDialog(title: title, content: content, actions: actions);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          media.padding.top + 32,
          24,
          media.padding.bottom + 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassDialogSurface(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
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
                    const SizedBox(height: 14),
                    DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      child: content,
                    ),
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...actions!.map(
                        (Widget action) => Padding(
                          padding: const EdgeInsets.only(top: 6),
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
