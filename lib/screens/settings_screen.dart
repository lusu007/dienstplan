import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dienstplan/widgets/settings/settings_section.dart';
import 'package:dienstplan/widgets/settings/settings_card.dart';
import 'package:dienstplan/widgets/settings/settings_switch_card.dart';
import 'package:dienstplan/widgets/dialogs/app_dialog.dart';
import 'package:dienstplan/widgets/dialogs/app_about_dialog.dart';
import 'package:dienstplan/widgets/dialogs/app_license_page.dart';
import 'package:dienstplan/dialogs/calendar_format_dialog.dart';
import 'package:dienstplan/dialogs/duty_schedule_dialog.dart';
import 'package:dienstplan/dialogs/language_dialog.dart';
import 'package:dienstplan/dialogs/preferred_duty_group_dialog.dart';
import 'package:dienstplan/dialogs/reset_dialog.dart';
import 'package:dienstplan/utils/app_info.dart';
import 'package:dienstplan/services/sentry_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = context.watch<LanguageService>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final sentryService = context.watch<SentryService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            _buildGeneralSection(
                context, l10n, languageService, scheduleProvider),
            const SizedBox(height: 16),
            _buildPrivacySection(context, l10n, sentryService),
            const SizedBox(height: 16),
            _buildLegalSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    AppLocalizations l10n,
    LanguageService languageService,
    ScheduleProvider scheduleProvider,
  ) {
    return SettingsSection(
      title: l10n.general,
      cards: [
        SettingsCard(
          icon: Icons.calendar_today,
          title: l10n.dutySchedule,
          subtitle:
              scheduleProvider.activeConfig?.meta.name ?? l10n.noDutySchedules,
          onTap: () => DutyScheduleDialog.show(context, scheduleProvider),
        ),
        SettingsCard(
          icon: Icons.favorite,
          title: l10n.preferredDutyGroup,
          subtitle:
              scheduleProvider.preferredDutyGroup ?? l10n.noPreferredDutyGroup,
          onTap: () => PreferredDutyGroupDialog.show(context, scheduleProvider),
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
      ],
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    AppLocalizations l10n,
    SentryService sentryService,
  ) {
    return SettingsSection(
      title: l10n.privacy,
      cards: [
        SettingsSwitchCard(
          icon: Icons.analytics,
          title: l10n.sentryAnalytics,
          subtitle: l10n.sentryAnalyticsDescription,
          value: sentryService.isEnabled,
          onChanged: (value) => sentryService.setEnabled(value),
        ),
        SettingsSwitchCard(
          icon: Icons.videocam,
          title: l10n.sentryReplay,
          subtitle: l10n.sentryReplayDescription,
          value: sentryService.isReplayEnabled,
          enabled: sentryService.isEnabled,
          onChanged: sentryService.isEnabled
              ? (value) => sentryService.setReplayEnabled(value)
              : null,
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.legal,
      cards: [
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

    await AppAboutDialog.show(
      context: context,
      appName: AppInfo.appName,
      appIconPath: AppInfo.appIconPath,
      appLegalese: AppInfo.appLegalese,
      contactEmail: AppInfo.contactEmail,
      children: [
        const SizedBox(height: 16),
        Text(l10n.aboutDescription),
        const SizedBox(height: 16),
        Text(l10n.aboutDisclaimer),
      ],
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.disclaimer,
      content: SingleChildScrollView(
        child: Text(l10n.disclaimerLong),
      ),
      showCloseButton: true,
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri privacyPolicyUri = Uri.parse(AppInfo.privacyPolicyUrl);
    if (await canLaunchUrl(privacyPolicyUri)) {
      await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
    AppLicensePage.show(
      context: context,
      appName: AppInfo.appName,
      appIconPath: AppInfo.appIconPath,
      appLegalese: AppInfo.appLegalese,
    );
  }
}
