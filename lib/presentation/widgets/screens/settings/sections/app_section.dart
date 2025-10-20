import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/language_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/theme_mode_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/calendar_format_bottomsheet.dart';
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

    // Get calendar format from settings
    final CalendarFormat calendarFormat =
        settingsState.value?.calendarFormat ?? CalendarFormat.month;

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
          onTap: () => LanguageBottomsheet.show(
            context,
            heightPercentage: 0.4, // 40% für einfache Sprachauswahl
          ),
        ),
        NavigationCard(
          icon: Icons.view_week_outlined,
          title: l10n.calendarFormat,
          subtitle: _getCalendarFormatName(calendarFormat, l10n),
          onTap: () => CalendarFormatBottomsheet.show(
            context,
            heightPercentage: 0.5, // 40% für einfache Kalenderformat-Auswahl
          ),
        ),
        NavigationCard(
          icon: Icons.color_lens_outlined,
          title: l10n.themeMode,
          subtitle: _themeSubtitle(l10n, effectivePref),
          trailing: _buildThemeIndicator(effectivePref),
          onTap: () => ThemeModeBottomsheet.show(
            context,
            ref,
            heightPercentage: 0.5, // 40% für einfache Design-Auswahl
          ),
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

  String _getCalendarFormatName(CalendarFormat format, AppLocalizations l10n) {
    switch (format) {
      case CalendarFormat.month:
        return l10n.calendarFormatMonth;
      case CalendarFormat.twoWeeks:
        return l10n.calendarFormatTwoWeeks;
      case CalendarFormat.week:
        return l10n.calendarFormatWeek;
    }
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

  Widget _buildThemeIndicator(ThemePreference pref) {
    switch (pref) {
      case ThemePreference.light:
        return const Icon(Icons.wb_sunny_outlined, color: Colors.amber);
      case ThemePreference.dark:
        return const Icon(Icons.nightlight_round, color: Colors.indigo);
      case ThemePreference.system:
        return const Icon(Icons.brightness_auto, color: Colors.grey);
    }
  }
}
