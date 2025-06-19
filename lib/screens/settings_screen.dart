import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dienstplan/widgets/settings_card.dart';
import 'package:dienstplan/widgets/section_header.dart';
import 'package:dienstplan/dialogs/calendar_format_dialog.dart';
import 'package:dienstplan/dialogs/duty_schedule_dialog.dart';
import 'package:dienstplan/dialogs/language_dialog.dart';
import 'package:dienstplan/dialogs/preferred_duty_group_dialog.dart';
import 'package:dienstplan/dialogs/reset_dialog.dart';
import 'package:dienstplan/constants/app_colors.dart';

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
            SectionHeader(title: l10n.general),
            SettingsCard(
              icon: Icons.calendar_today,
              title: l10n.dutySchedule,
              subtitle: scheduleProvider.activeConfig?.meta.name ??
                  l10n.noDutySchedules,
              onTap: () => DutyScheduleDialog.show(context, scheduleProvider),
            ),
            SettingsCard(
              icon: Icons.favorite,
              title: l10n.preferredDutyGroup,
              subtitle: scheduleProvider.preferredDutyGroup ??
                  l10n.noPreferredDutyGroup,
              onTap: () =>
                  PreferredDutyGroupDialog.show(context, scheduleProvider),
            ),
            SettingsCard(
              icon: Icons.view_week,
              title: l10n.calendarFormat,
              subtitle:
                  _getCalendarFormatName(scheduleProvider.calendarFormat, l10n),
              onTap: () => CalendarFormatDialog.show(context, scheduleProvider),
            ),
            SettingsCard(
              icon: Icons.language,
              title: l10n.language,
              subtitle: languageService.currentLocale.languageCode == 'de'
                  ? l10n.german
                  : l10n.english,
              onTap: () => LanguageDialog.show(context),
            ),
            SettingsCard(
              icon: Icons.delete_forever,
              title: l10n.resetData,
              onTap: () => ResetDialog.show(context, scheduleProvider),
            ),
            const SizedBox(height: 16),
            // Rechtliches (Legal) Section
            SectionHeader(title: l10n.legal),
            SettingsCard(
              icon: Icons.info_outline,
              title: l10n.about,
              onTap: () => _showAboutDialog(context),
            ),
            SettingsCard(
              icon: Icons.warning_outlined,
              title: l10n.disclaimer,
              onTap: () => _showDisclaimerDialog(context),
            ),
            SettingsCard(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () => _openPrivacyPolicy(),
            ),
            SettingsCard(
              icon: Icons.description_outlined,
              title: l10n.licenses,
              onTap: () => _showLicenses(context),
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

  Future<void> _showAboutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
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
  }

  void _showDisclaimerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disclaimer),
        content: SingleChildScrollView(
          child: Text(l10n.aboutDisclaimer),
        ),
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri privacyPolicyUri =
        Uri.parse('https://assets.scelus.io/datenschutz.html');
    if (await canLaunchUrl(privacyPolicyUri)) {
      await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
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
  }
}
