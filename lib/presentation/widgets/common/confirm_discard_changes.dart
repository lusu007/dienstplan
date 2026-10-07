import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await GlassAppDialog.show<bool>(
        context: context,
        title: l10n.discardChangesTitle,
        content: Text(l10n.discardChangesMessage),
        actions: [
          AppGlassButton(
            fullWidth: true,
            role: AppGlassButtonRole.primary,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditing),
          ),
          AppGlassButton(
            fullWidth: true,
            role: AppGlassButtonRole.destructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discardChanges),
          ),
        ],
      ) ==
      true;
}
