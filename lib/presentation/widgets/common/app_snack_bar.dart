import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/app_feedback_style.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:flutter/material.dart';

/// Library-backed glass, with ScaffoldMessenger's queue, route handoff and
/// dismissal behavior. Unlike GlassToast, messages can wrap without truncation.
class AppSnackBar extends SnackBar {
  AppSnackBar({
    super.key,
    required Widget content,
    super.duration,
    SnackBarAction? action,
    Color? backgroundColor,
    SnackBarBehavior super.behavior = SnackBarBehavior.floating,
  }) : super(
         content: _FeedbackContent(
           content: content,
           action: action,
           fill: backgroundColor,
         ),
         persist: action != null,
         backgroundColor: Colors.transparent,
         elevation: 0,
         padding: EdgeInsets.zero,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(glassSurfaceRadiusMd),
         ),
       );
}

class _FeedbackContent extends StatelessWidget {
  const _FeedbackContent({required this.content, this.action, this.fill});
  final Widget content;
  final SnackBarAction? action;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = DefaultTextStyle.merge(
      style: AppFeedbackStyle.text(scheme),
      child: content,
    );
    return AppGlassSurface(
      borderRadius: glassSurfaceRadiusMd,
      tint: scheme.surface.withValues(alpha: .10),
      borderColor: AppFeedbackStyle.border(scheme),
      child: ColoredBox(
        color: fill ?? AppFeedbackStyle.fill(scheme),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: action == null
              ? text
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    text,
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: action!),
                  ],
                ),
        ),
      ),
    );
  }
}
