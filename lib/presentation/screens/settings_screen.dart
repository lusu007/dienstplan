import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:get_it/get_it.dart';

import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card_skeleton.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card_skeleton.dart';

import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/calendar_format_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/duty_schedule_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/language_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/my_duty_group_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/reset_dialog.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/screens/debug_screen.dart';
import 'package:dienstplan/presentation/screens/about_screen.dart';
import 'package:dienstplan/data/services/share_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<ScheduleController> _scheduleControllerFuture;
  int _footerTapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    // Get the controller and ensure all data is loaded
    _scheduleControllerFuture = _getFullyLoadedController();
  }

  Future<ScheduleController> _getFullyLoadedController() async {
    final controller = await GetIt.instance.getAsync<ScheduleController>();

    // Ensure configs and settings are loaded
    if (controller.configs.isEmpty ||
        controller.activeConfig == null ||
        controller.preferredDutyGroup == null) {
      await controller.loadConfigs();
    }

    return controller;
  }

  @override
  void dispose() {
    super.dispose();
    // Refresh the UI after settings screen is closed
    GetIt.instance.getAsync<ScheduleController>().then((controller) {
      controller.refreshAfterSettingsClose();
    }).catchError((e, stackTrace) {
      AppLogger.e(
          'SettingsScreen: Error refreshing after close', e, stackTrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: FutureBuilder<ScheduleController>(
        future: _scheduleControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show skeleton loader instead of circular progress indicator
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  _buildScheduleSectionSkeleton(context, l10n),
                  const SizedBox(height: 16),
                  _buildAppSectionSkeleton(context, l10n),
                  const SizedBox(height: 16),
                  _buildPrivacySectionSkeleton(context, l10n),
                  const SizedBox(height: 16),
                  _buildOtherSectionSkeleton(context, l10n),
                ],
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading settings: ${snapshot.error}'),
                ],
              ),
            );
          }

          final scheduleController = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                _buildScheduleSection(context, l10n, scheduleController),
                const SizedBox(height: 16),
                _buildAppSection(context, l10n, scheduleController),
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: GetIt.instance<SentryService>(),
                  builder: (context, child) =>
                      _buildPrivacySection(context, l10n),
                ),
                const SizedBox(height: 16),
                _buildOtherSection(context, l10n),
                const SizedBox(height: 32),
                _buildFooterSection(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleController scheduleController,
  ) {
    return ListenableBuilder(
      listenable: scheduleController,
      builder: (context, child) {
        // Show skeleton loader if controller is loading
        if (scheduleController.isLoading) {
          return _buildScheduleSectionSkeleton(context, l10n);
        }

        // Show error message if there's an error
        if (scheduleController.error != null) {
          return SettingsSection(
            title: l10n.schedule,
            cards: [
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${scheduleController.error}',
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SettingsSection(
          title: l10n.schedule,
          cards: [
            NavigationCard(
              icon: Icons.calendar_today_outlined,
              title: l10n.myDutySchedule,
              subtitle: _getDutyScheduleDisplayName(scheduleController, l10n),
              onTap: () => DutyScheduleDialog.show(context, scheduleController),
            ),
            NavigationCard(
              icon: Icons.favorite_outlined,
              title: l10n.myDutyGroup,
              subtitle:
                  _getPreferredDutyGroupDisplayName(scheduleController, l10n),
              onTap: () => MyDutyGroupDialog.show(context, scheduleController),
            ),
            NavigationCard(
              icon: Icons.view_week_outlined,
              title: l10n.calendarFormat,
              subtitle: _getCalendarFormatName(
                  scheduleController.calendarFormat, l10n),
              onTap: () =>
                  CalendarFormatDialog.show(context, scheduleController),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppSection(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleController scheduleController,
  ) {
    final languageService = GetIt.instance<LanguageService>();

    return ListenableBuilder(
      listenable: scheduleController,
      builder: (context, child) {
        // Show skeleton loader if controller is loading
        if (scheduleController.isLoading) {
          return _buildAppSectionSkeleton(context, l10n);
        }

        return SettingsSection(
          title: l10n.app,
          cards: [
            NavigationCard(
              icon: Icons.language_outlined,
              title: l10n.language,
              subtitle: languageService.currentLocale.languageCode == 'de'
                  ? l10n.german
                  : l10n.english,
              onTap: () => LanguageDialog.show(context),
            ),
            NavigationCard(
              icon: Icons.delete_forever_outlined,
              title: l10n.resetData,
              onTap: () => ResetDialog.show(context, scheduleController),
              iconColor: Colors.red,
            ),
          ],
        );
      },
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
        ToggleCard(
          icon: Icons.analytics_outlined,
          title: l10n.sentryAnalytics,
          subtitle: l10n.sentryAnalyticsDescription,
          value: sentryService.isEnabled,
          onChanged: (value) => sentryService.setEnabled(value),
        ),
        ToggleCard(
          icon: Icons.videocam_outlined,
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

  Widget _buildOtherSection(BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.other,
      cards: [
        NavigationCard(
          icon: Icons.info_outline,
          title: l10n.about,
          onTap: () => _navigateToAboutScreen(context),
        ),
        NavigationCard(
          icon: Icons.email_outlined,
          title: l10n.contact,
          subtitle: l10n.contactDescription,
          onTap: () => _openContact(),
        ),
        NavigationCard(
          icon: Icons.share_outlined,
          title: l10n.shareApp,
          subtitle: l10n.shareAppDescription,
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  Widget _buildOtherSectionSkeleton(
      BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.other,
      cards: [
        NavigationCardSkeleton(
          icon: Icons.info_outline,
          title: l10n.about,
          showSubtitleSkeleton: false,
        ),
        NavigationCardSkeleton(
          icon: Icons.email_outlined,
          title: l10n.contact,
          showSubtitleSkeleton: false,
        ),
        NavigationCardSkeleton(
          icon: Icons.share_outlined,
          title: l10n.shareApp,
          showSubtitleSkeleton: false,
        ),
      ],
    );
  }

  Widget _buildScheduleSectionSkeleton(
      BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.schedule,
      cards: [
        NavigationCardSkeleton(
          icon: Icons.calendar_today_outlined,
          title: l10n.dutySchedule,
          showSubtitleSkeleton: true, // Dynamisch geladen
        ),
        NavigationCardSkeleton(
          icon: Icons.favorite_outlined,
          title: l10n.myDutyGroup,
          showSubtitleSkeleton: true, // Dynamisch geladen
        ),
        NavigationCardSkeleton(
          icon: Icons.view_week_outlined,
          title: l10n.calendarFormat,
          showSubtitleSkeleton: true, // Dynamisch geladen
        ),
      ],
    );
  }

  Widget _buildAppSectionSkeleton(BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.app,
      cards: [
        NavigationCardSkeleton(
          icon: Icons.language_outlined,
          title: l10n.language,
          showSubtitleSkeleton: false, // Statisch
        ),
        NavigationCardSkeleton(
          icon: Icons.delete_forever_outlined,
          title: l10n.resetData,
          showSubtitleSkeleton: false, // Kein Subtitle
        ),
      ],
    );
  }

  Widget _buildPrivacySectionSkeleton(
      BuildContext context, AppLocalizations l10n) {
    final sentryService = GetIt.instance<SentryService>();

    return SettingsSection(
      title: l10n.privacy,
      cards: [
        ToggleCardSkeleton(
          icon: Icons.analytics_outlined,
          title: l10n.sentryAnalytics,
          subtitle: l10n.sentryAnalyticsDescription,
          showSubtitleSkeleton: false, // Statisch
          value: sentryService.isEnabled,
          enabled: true,
        ),
        ToggleCardSkeleton(
          icon: Icons.videocam_outlined,
          title: l10n.sentryReplay,
          subtitle: l10n.sentryReplayDescription,
          showSubtitleSkeleton: false, // Statisch
          value: sentryService.isReplayEnabled,
          enabled: sentryService.isEnabled,
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
    try {
      if (scheduleController.activeConfig == null) {
        return l10n.noDutySchedules;
      }
      return scheduleController.activeConfig!.meta.name;
    } catch (e) {
      AppLogger.e(
          'SettingsScreen: Error getting duty schedule display name', e);
      return l10n.noDutySchedules;
    }
  }

  String _getPreferredDutyGroupDisplayName(
    ScheduleController scheduleController,
    AppLocalizations l10n,
  ) {
    try {
      if (scheduleController.preferredDutyGroup == null ||
          scheduleController.preferredDutyGroup!.isEmpty) {
        return l10n.noMyDutyGroup;
      }
      return scheduleController.preferredDutyGroup!;
    } catch (e) {
      AppLogger.e(
          'SettingsScreen: Error getting preferred duty group display name', e);
      return l10n.noMyDutyGroup;
    }
  }

  void _navigateToAboutScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  Future<void> _openContact() async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: AppInfo.contactEmail,
      );
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e, stackTrace) {
      AppLogger.e('SettingsScreen: Error opening contact email', e, stackTrace);
    }
  }

  Future<void> _shareApp() async {
    try {
      final l10n = AppLocalizations.of(context);
      await ShareService.shareApp(l10n);
    } catch (e, stackTrace) {
      AppLogger.e('SettingsScreen: Error sharing app', e, stackTrace);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareAppError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFooterSection(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _handleFooterTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppInfo.appLegalese,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: AppInfo.fullVersion,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                );
              }
              return Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleFooterTap() {
    final now = DateTime.now();

    // Reset counter if more than 3 seconds have passed since last tap
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 3) {
      _footerTapCount = 0;
    }

    _footerTapCount++;
    _lastTapTime = now;

    // Open debug screen after 7 taps
    if (_footerTapCount >= 7) {
      _footerTapCount = 0; // Reset counter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DebugScreen(),
        ),
      );
    }
  }
}
