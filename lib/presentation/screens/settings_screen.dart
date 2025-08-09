import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
// Sentry service is accessed through providers

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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _footerTapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final scheduleAsync = ref.watch(scheduleNotifierProvider);
    return scheduleAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: Padding(
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
        ),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $e'),
            ],
          ),
        ),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              _buildScheduleSection(context, l10n, state),
              const SizedBox(height: 16),
              _buildAppSection(context, l10n),
              const SizedBox(height: 16),
              Consumer(builder: (context, ref, _) {
                final sentryAsync = ref.watch(sentryServiceProvider);
                return sentryAsync.when(
                  loading: () => _buildPrivacySectionSkeleton(context, l10n),
                  error: (e, st) => _buildPrivacySectionSkeleton(context, l10n),
                  data: (_) => _buildPrivacySection(context, l10n),
                );
              }),
              const SizedBox(height: 16),
              _buildOtherSection(context, l10n),
              const SizedBox(height: 32),
              _buildFooterSection(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    AppLocalizations l10n,
    ScheduleUiState state,
  ) {
    return SettingsSection(
      title: l10n.schedule,
      cards: [
        NavigationCard(
          icon: Icons.calendar_today_outlined,
          title: l10n.myDutySchedule,
          subtitle: _getDutyScheduleDisplayName(state, l10n),
          onTap: () => DutyScheduleDialog.show(context),
        ),
        NavigationCard(
          icon: Icons.favorite_outlined,
          title: l10n.myDutyGroup,
          subtitle: _getPreferredDutyGroupDisplayName(state, l10n),
          onTap: () => MyDutyGroupDialog.show(context),
        ),
        NavigationCard(
          icon: Icons.view_week_outlined,
          title: l10n.calendarFormat,
          subtitle: _getCalendarFormatName(
              state.calendarFormat ?? CalendarFormat.month, l10n),
          onTap: () => CalendarFormatDialog.show(context),
        ),
      ],
    );
  }

  Widget _buildAppSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final languageService = ref.watch(languageServiceProvider).value;

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
          icon: Icons.delete_forever_outlined,
          title: l10n.resetData,
          onTap: () => ResetDialog.show(context),
          iconColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final sentryService = ref.watch(sentryServiceProvider).value;
    return SettingsSection(
      title: l10n.privacy,
      cards: [
        ToggleCard(
          icon: Icons.analytics_outlined,
          title: l10n.sentryAnalytics,
          subtitle: l10n.sentryAnalyticsDescription,
          value: sentryService?.isEnabled ?? false,
          onChanged: (value) => sentryService?.setEnabled(value),
        ),
        ToggleCard(
          icon: Icons.videocam_outlined,
          title: l10n.sentryReplay,
          subtitle: l10n.sentryReplayDescription,
          value: sentryService?.isReplayEnabled ?? false,
          enabled: sentryService?.isEnabled ?? false,
          onChanged: (sentryService?.isEnabled ?? false)
              ? (value) => sentryService?.setReplayEnabled(value)
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
    return SettingsSection(
      title: l10n.privacy,
      cards: [
        ToggleCardSkeleton(
          icon: Icons.analytics_outlined,
          title: l10n.sentryAnalytics,
          subtitle: l10n.sentryAnalyticsDescription,
          showSubtitleSkeleton: false, // Statisch
          value: false,
          enabled: true,
        ),
        ToggleCardSkeleton(
          icon: Icons.videocam_outlined,
          title: l10n.sentryReplay,
          subtitle: l10n.sentryReplayDescription,
          showSubtitleSkeleton: false, // Statisch
          value: false,
          enabled: false,
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
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.activeConfigName ?? '').isEmpty) {
        return l10n.noDutySchedules;
      }
      return state.activeConfig?.meta.name ?? state.activeConfigName!;
    } catch (e) {
      AppLogger.e(
          'SettingsScreen: Error getting duty schedule display name', e);
      return l10n.noDutySchedules;
    }
  }

  String _getPreferredDutyGroupDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.preferredDutyGroup ?? '').isEmpty) {
        return l10n.noMyDutyGroup;
      }
      return state.preferredDutyGroup!;
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
