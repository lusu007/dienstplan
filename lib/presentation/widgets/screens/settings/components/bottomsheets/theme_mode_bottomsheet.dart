import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/selection_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class ThemeModeBottomsheet {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    double? heightPercentage,
  }) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(settingsProvider).value;
          final current = state?.themePreference ?? ThemePreference.system;

          return SelectionBottomsheet(
            title: l10n.themeMode,
            heightPercentage: heightPercentage,
            items: [
              SelectionItem(
                title: l10n.themeModeLight,
                value: ThemePreference.light.name,
              ),
              SelectionItem(
                title: l10n.themeModeDark,
                value: ThemePreference.dark.name,
              ),
              SelectionItem(
                title: l10n.themeModeSystem,
                value: ThemePreference.system.name,
              ),
            ],
            selectedValue: current.name,
            onItemSelected: (themeName) async {
              if (themeName != null) {
                ThemePreference preference;
                switch (themeName) {
                  case 'light':
                    preference = ThemePreference.light;
                    break;
                  case 'dark':
                    preference = ThemePreference.dark;
                    break;
                  case 'system':
                    preference = ThemePreference.system;
                    break;
                  default:
                    preference = ThemePreference.system;
                }
                await ref
                    .read(settingsProvider.notifier)
                    .setThemePreference(preference);
              }
            },
          );
        },
      ),
    );
  }
}
