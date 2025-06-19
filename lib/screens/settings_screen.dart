import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/screens/first_time_setup_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
            leading: const Icon(Icons.language),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
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
            title: Text(l10n.preferredDutyGroup),
            subtitle: Text(
              scheduleProvider.preferredDutyGroup ?? l10n.noPreferredDutyGroup,
            ),
            leading: const Icon(Icons.favorite),
            onTap: () =>
                _showPreferredDutyGroupDialog(context, scheduleProvider),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.about),
            leading: const Icon(Icons.info_outline),
            onTap: () async {
              final packageInfo = await PackageInfo.fromPlatform();
              if (context.mounted) {
                showAboutDialog(
                  context: context,
                  applicationName: 'Dienstplan',
                  applicationVersion: packageInfo.version,
                  applicationIcon: Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                  ),
                  applicationLegalese: '© ${DateTime.now().year} Lukas Jost',
                  children: [
                    const SizedBox(height: 16),
                    Text(l10n.aboutDescription),
                    const SizedBox(height: 16),
                    Text(l10n.aboutDisclaimer),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'hi@scelus.io',
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        }
                      },
                      child: const Text(
                        'hi@scelus.io',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
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

  void _showPreferredDutyGroupDialog(
      BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectPreferredDutyGroup),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Fixed height to prevent dialog from being too tall
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(l10n.noPreferredDutyGroup),
                        leading: Icon(
                          provider.preferredDutyGroup == null
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: provider.preferredDutyGroup == null
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        onTap: () {
                          provider.preferredDutyGroup = null;
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      ...provider.dutyGroups.map((group) => ListTile(
                            title: Text(group),
                            leading: Icon(
                              provider.preferredDutyGroup == group
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: provider.preferredDutyGroup == group
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            onTap: () {
                              provider.preferredDutyGroup = group;
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
