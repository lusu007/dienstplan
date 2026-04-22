import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';

/// Thin compatibility wrapper that keeps the old [AppDialog.show] API while
/// rendering the dialog in the new glass-morphism style.
class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    Color? mainColor,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color accent = mainColor ?? Theme.of(context).colorScheme.primary;

    final List<Widget> mergedActions = <Widget>[
      if (actions != null) ...actions,
      if (showCloseButton)
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              l10n.close,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
          ),
        ),
    ];

    return GlassAppDialog.show<T>(
      context: context,
      title: title,
      content: content,
      actions: mergedActions,
    );
  }
}
