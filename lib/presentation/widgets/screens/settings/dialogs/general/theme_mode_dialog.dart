import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';

class ThemeModeDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _ThemeModeDialogContent(),
    );
  }
}

class _ThemeModeDialogContent extends ConsumerStatefulWidget {
  const _ThemeModeDialogContent();

  @override
  ConsumerState<_ThemeModeDialogContent> createState() =>
      _ThemeModeDialogContentState();
}

class _ThemeModeDialogContentState
    extends ConsumerState<_ThemeModeDialogContent> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(settingsNotifierProvider).valueOrNull;
    final ThemePreference current =
        state?.themePreference ?? ThemePreference.light;

    return AlertDialog(
      title: Text(l10n.themeMode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemePreference>(
            title: Text(l10n.themeModeLight),
            value: ThemePreference.light,
            groupValue: current,
            onChanged: (val) {
              if (val == null) return;
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setThemePreference(val);
            },
          ),
          RadioListTile<ThemePreference>(
            title: Text(l10n.themeModeDark),
            value: ThemePreference.dark,
            groupValue: current,
            onChanged: (val) {
              if (val == null) return;
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setThemePreference(val);
            },
          ),
          RadioListTile<ThemePreference>(
            title: Text(l10n.themeModeSystem),
            value: ThemePreference.system,
            groupValue: current,
            onChanged: (val) {
              if (val == null) return;
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setThemePreference(val);
            },
          ),
        ],
      ),
    );
  }
}
