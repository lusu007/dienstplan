import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/language_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/theme_mode_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart';
import 'package:dienstplan/domain/entities/settings.dart' show ThemePreference;

class AppSection extends ConsumerWidget {
  const AppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final languageService = ref.watch(languageServiceProvider).value;
    final settingsState = ref.watch(settingsProvider);

    // Use settings preference directly, fallback to light mode
    final ThemePreference effectivePref =
        settingsState.value?.themePreference ?? ThemePreference.system;

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
          onTap: () => LanguageBottomsheet.show(context),
        ),
        NavigationCard(
          icon: Icons.color_lens_outlined,
          title: l10n.themeMode,
          subtitle: _themeSubtitle(l10n, effectivePref),
          trailing: _buildThemeIndicator(context, effectivePref),
          onTap: () => ThemeModeBottomsheet.show(context, ref),
        ),
        NavigationCard(
          icon: Icons.delete_forever_outlined,
          title: l10n.resetData,
          onTap: () => ResetBottomsheet.show(context),
          iconColor: Colors.red,
        ),
      ],
    );
  }

  String _themeSubtitle(AppLocalizations l10n, ThemePreference pref) {
    switch (pref) {
      case ThemePreference.light:
        return l10n.themeModeLight;
      case ThemePreference.dark:
        return l10n.themeModeDark;
      case ThemePreference.system:
        return l10n.themeModeSystem;
    }
  }

  Widget _buildThemeIndicator(BuildContext context, ThemePreference pref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (pref) {
      case ThemePreference.light:
        return Icon(Icons.wb_sunny_outlined, color: colorScheme.secondary);
      case ThemePreference.dark:
        return Icon(Icons.nightlight_round, color: colorScheme.primary);
      case ThemePreference.system:
        return Icon(Icons.brightness_auto, color: colorScheme.onSurfaceVariant);
    }
  }
}
