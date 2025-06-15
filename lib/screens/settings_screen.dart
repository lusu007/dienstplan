import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/screens/first_time_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.watch<LanguageService>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(
              languageService.currentLocale.languageCode == 'de'
                  ? l10n.german
                  : l10n.english,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(context),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.dutySchedule),
            subtitle: Text(scheduleProvider.activeConfig?.meta.name ??
                l10n.noDutySchedules),
            leading: const Icon(Icons.calendar_today),
            onTap: () => _showDutyScheduleDialog(context, scheduleProvider),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.calendarFormat),
            subtitle: Text(
                _getCalendarFormatName(scheduleProvider.calendarFormat, l10n)),
            leading: const Icon(Icons.view_week),
            onTap: () => _showCalendarFormatDialog(context, scheduleProvider),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.resetData),
            leading: const Icon(Icons.delete_forever),
            onTap: () => _showResetDialog(context, scheduleProvider),
          ),
        ],
      ),
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

  void _showCalendarFormatDialog(
      BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.calendarFormatMonth),
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.month);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.calendarFormatTwoWeeks),
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.twoWeeks);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.calendarFormatWeek),
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.week);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDutyScheduleDialog(
      BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDutySchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...provider.configs.map((config) => ListTile(
                  title: Text(config.meta.name),
                  onTap: () {
                    provider.setActiveConfig(config);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetData),
        content: Text(l10n.resetDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.reset();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.resetDataSuccess),
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const FirstTimeSetupScreen(),
                  ),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.read<LanguageService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.german),
              onTap: () {
                languageService.setLanguage('de');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                languageService.setLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
