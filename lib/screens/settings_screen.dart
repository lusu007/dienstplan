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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Allgemein (General) Section
            ListTile(
              title: Text(
                l10n.general,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.language,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  languageService.currentLocale.languageCode == 'de'
                      ? l10n.german
                      : l10n.english,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () => _showLanguageDialog(context),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.calendar_today,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.dutySchedule,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  scheduleProvider.activeConfig?.meta.name ??
                      l10n.noDutySchedules,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () => _showDutyScheduleDialog(context, scheduleProvider),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.view_week,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.calendarFormat,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  _getCalendarFormatName(scheduleProvider.calendarFormat, l10n),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () =>
                    _showCalendarFormatDialog(context, scheduleProvider),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.favorite,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.preferredDutyGroup,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  scheduleProvider.preferredDutyGroup ??
                      l10n.noPreferredDutyGroup,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () =>
                    _showPreferredDutyGroupDialog(context, scheduleProvider),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.delete_forever,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.resetData,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () => _showResetDialog(context, scheduleProvider),
              ),
            ),
            const SizedBox(height: 16),
            // Rechtliches (Legal) Section
            ListTile(
              title: Text(
                l10n.legal,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.info_outline,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.about,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
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
                      applicationLegalese:
                          '© ${DateTime.now().year} Lukas Jost',
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
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.warning_outlined,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.disclaimer,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.disclaimer),
                      content: SingleChildScrollView(
                        child: Text(l10n.aboutDisclaimer),
                      ),
                      actions: [
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005B8C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  minimumSize: const Size.fromHeight(56),
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.privacyPolicy,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () async {
                  final Uri privacyPolicyUri =
                      Uri.parse('https://assets.scelus.io/datenschutz.html');
                  if (await canLaunchUrl(privacyPolicyUri)) {
                    await launchUrl(privacyPolicyUri,
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                minVerticalPadding: 20,
                leading: const Icon(Icons.description_outlined,
                    color: Color(0xFF005B8C), size: 40),
                title: Text(
                  l10n.licenses,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selectedTileColor: Colors.transparent,
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Dienstplan',
                    applicationVersion: '1.0.0',
                    applicationIcon: Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                    ),
                    applicationLegalese: '© ${DateTime.now().year} Lukas Jost',
                  );
                },
              ),
            ),
          ],
        ),
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
    const mainColor = Color(0xFF005B8C);
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
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDutyScheduleDialog(
      BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    const mainColor = Color(0xFF005B8C);
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
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    const mainColor = Color(0xFF005B8C);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetData),
        content: Text(l10n.resetDataConfirmation),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: mainColor,
                      side: const BorderSide(color: mainColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.read<LanguageService>();
    const mainColor = Color(0xFF005B8C);

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
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreferredDutyGroupDialog(
      BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);
    const mainColor = Color(0xFF005B8C);
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
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
