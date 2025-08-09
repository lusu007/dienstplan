import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';

class ThemeModeDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(settingsNotifierProvider).valueOrNull;
    final ThemePreference current =
        state?.themePreference ?? ThemePreference.light;

    ThemePreference selected = current;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.themeMode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemePreference>(
                title: Text(l10n.themeModeLight),
                value: ThemePreference.light,
                groupValue: selected,
                onChanged: (val) {
                  if (val == null) return;
                  selected = val;
                  Navigator.of(ctx).pop();
                  _applySelection(context, ref, selected, l10n);
                },
              ),
              RadioListTile<ThemePreference>(
                title: Text(l10n.themeModeDark),
                value: ThemePreference.dark,
                groupValue: selected,
                onChanged: (val) {
                  if (val == null) return;
                  selected = val;
                  Navigator.of(ctx).pop();
                  _applySelection(context, ref, selected, l10n);
                },
              ),
              RadioListTile<ThemePreference>(
                title: Text(l10n.themeModeSystem),
                value: ThemePreference.system,
                groupValue: selected,
                onChanged: (val) {
                  if (val == null) return;
                  selected = val;
                  Navigator.of(ctx).pop();
                  _applySelection(context, ref, selected, l10n);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  static void _applySelection(BuildContext context, WidgetRef ref,
      ThemePreference preference, AppLocalizations l10n) {
    ref.read(settingsNotifierProvider.notifier).setThemePreference(preference);
    if (preference != ThemePreference.light) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.darkModeNotAvailableYet)),
      );
    }
  }
}
