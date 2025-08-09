import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/language_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/theme_mode_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/reset_dialog.dart';
import 'package:dienstplan/domain/entities/settings.dart' show ThemePreference;

class AppSection extends ConsumerWidget {
  const AppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final languageService = ref.watch(languageServiceProvider).value;
    final ThemePreference? themePref =
        ref.watch(settingsNotifierProvider).valueOrNull?.themePreference;

    return SettingsSection(
      title: l10n.app,
      cards: [
        NavigationCard(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle:
              (languageService?.currentLocale.languageCode ?? 'de') == 'de'
                  ? l10n.german
                  : l10n.english,
          onTap: () => LanguageDialog.show(context),
        ),
        NavigationCard(
          icon: Icons.color_lens_outlined,
          title: l10n.themeMode,
          subtitle: _themeSubtitle(l10n, themePref),
          trailing: _buildThemeIndicator(themePref),
          onTap: () => ThemeModeDialog.show(context, ref),
        ),
        NavigationCard(
          icon: Icons.delete_forever_outlined,
          title: l10n.resetData,
          onTap: () => ResetDialog.show(context),
          iconColor: Colors.red,
        ),
      ],
    );
  }

  String _themeSubtitle(AppLocalizations l10n, ThemePreference? pref) {
    switch (pref) {
      case ThemePreference.light:
        return l10n.themeModeLight;
      case ThemePreference.dark:
        return l10n.themeModeDark;
      case ThemePreference.system:
      case null:
        return l10n.themeModeSystem;
    }
  }

  Widget _buildThemeIndicator(ThemePreference? pref) {
    switch (pref) {
      case ThemePreference.light:
        return const Icon(Icons.wb_sunny_outlined, color: Colors.amber);
      case ThemePreference.dark:
        return const Icon(Icons.nightlight_round, color: Colors.indigo);
      case ThemePreference.system:
      case null:
        return const Icon(Icons.brightness_auto, color: Colors.grey);
    }
  }
}
