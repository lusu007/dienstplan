import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/settings/settings_card.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/settings/settings_switch_card.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/app_dialog.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/app_about_dialog.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/app_license_page.dart';
import 'package:dienstplan/presentation/widgets/dialogs/calendar_format_dialog.dart';
import 'package:dienstplan/presentation/widgets/dialogs/duty_schedule_dialog.dart';
import 'package:dienstplan/presentation/widgets/dialogs/language_dialog.dart';
import 'package:dienstplan/presentation/widgets/dialogs/preferred_duty_group_dialog.dart';
import 'package:dienstplan/presentation/widgets/dialogs/reset_dialog.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/data/services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<ScheduleController> _initializeScheduleController() async {
    final scheduleController =
        await GetIt.instance.getAsync<ScheduleController>();

    // Load configs if not already loaded
    if (scheduleController.configs.isEmpty) {
      await scheduleController.loadConfigs();
    }

    // Ensure settings are loaded by calling loadConfigs again if needed
    // This will reload all settings including activeConfig and preferredDutyGroup
    if (scheduleController.activeConfig == null ||
        scheduleController.preferredDutyGroup == null) {
      print(
          'DEBUG SettingsScreen: Reloading configs to ensure settings are loaded');
      await scheduleController.loadConfigs();
    }

    print(
        'DEBUG SettingsScreen: Active config: ${scheduleController.activeConfig?.name}');
    print(
        'DEBUG SettingsScreen: Preferred duty group: ${scheduleController.preferredDutyGroup}');

    return scheduleController;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<ScheduleController>(
      future: _initializeScheduleController(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final scheduleController = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                ListenableBuilder(
                  listenable: scheduleController,
                  builder: (context, child) =>
                      _buildGeneralSection(context, l10n, scheduleController),
                ),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: GetIt.instance<SentryService>(),
                  builder: (context, child) =>
                      _buildPrivacySection(context, l10n),
                ),
                const SizedBox(height: 16),
                _buildLegalSection(context, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleController scheduleController,
  ) {
    final languageService = GetIt.instance<LanguageService>();
    return SettingsSection(
      title: l10n.general,
      cards: [
        SettingsCard(
          icon: Icons.calendar_today,
          title: l10n.dutySchedule,
          subtitle: _getDutyScheduleDisplayName(scheduleController, l10n),
          onTap: () => DutyScheduleDialog.show(context, scheduleController),
        ),
        SettingsCard(
          icon: Icons.favorite,
          title: l10n.preferredDutyGroup,
          subtitle: _getPreferredDutyGroupDisplayName(scheduleController, l10n),
          onTap: () =>
              PreferredDutyGroupDialog.show(context, scheduleController),
        ),
        SettingsCard(
          icon: Icons.view_week,
          title: l10n.calendarFormat,
          subtitle:
              _getCalendarFormatName(scheduleController.calendarFormat, l10n),
          onTap: () => CalendarFormatDialog.show(context, scheduleController),
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
          onTap: () => ResetDialog.show(context, scheduleController),
        ),
        SettingsCard(
          icon: Icons.refresh,
          title: 'Regenerate Schedules (Debug)',
          subtitle: 'Fix service field issue',
          onTap: () async {
            final now = DateTime.now();
            final startDate = DateTime(now.year - 1, 1, 1);
            final endDate = DateTime(now.year + 1, 12, 31);
            await scheduleController.regenerateAllSchedules(startDate, endDate);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedules regenerated')),
              );
            }
          },
        ),
        SettingsCard(
          icon: Icons.settings,
          title: 'Set Active Config (Debug)',
          subtitle:
              'Current: ${scheduleController.activeConfig?.name ?? 'None'}',
          onTap: () async {
            // Show a dialog to select the active config
            final configName = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Active Config'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: scheduleController.configs
                      .map((config) => ListTile(
                            title: Text(config.name),
                            subtitle: Text(config.meta.description),
                            onTap: () => Navigator.pop(context, config.name),
                          ))
                      .toList(),
                ),
              ),
            );

            if (configName != null) {
              final config = scheduleController.configs.firstWhere(
                (config) => config.name == configName,
              );
              await scheduleController.setActiveConfig(config);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Active config set to: $configName')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final sentryService = GetIt.instance<SentryService>();
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

  String _getDutyScheduleDisplayName(
    ScheduleController scheduleController,
    AppLocalizations l10n,
  ) {
    if (scheduleController.activeConfig == null) {
      return l10n.noDutySchedules;
    }
    return scheduleController.activeConfig!.meta.name;
  }

  String _getPreferredDutyGroupDisplayName(
    ScheduleController scheduleController,
    AppLocalizations l10n,
  ) {
    if (scheduleController.preferredDutyGroup == null ||
        scheduleController.preferredDutyGroup!.isEmpty) {
      return l10n.noPreferredDutyGroup;
    }
    return scheduleController.preferredDutyGroup!;
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
