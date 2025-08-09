import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card_skeleton.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final sentryAsync = ref.watch(sentryServiceProvider);

    return sentryAsync.when(
      loading: () => SettingsSection(
        title: l10n.privacy,
        cards: [
          ToggleCardSkeleton(
            icon: Icons.analytics_outlined,
            title: l10n.sentryAnalytics,
            subtitle: l10n.sentryAnalyticsDescription,
            showSubtitleSkeleton: false,
            value: false,
            enabled: true,
          ),
          ToggleCardSkeleton(
            icon: Icons.videocam_outlined,
            title: l10n.sentryReplay,
            subtitle: l10n.sentryReplayDescription,
            showSubtitleSkeleton: false,
            value: false,
            enabled: false,
          ),
        ],
      ),
      error: (e, st) => SettingsSection(
        title: l10n.privacy,
        cards: [
          ToggleCardSkeleton(
            icon: Icons.analytics_outlined,
            title: l10n.sentryAnalytics,
            subtitle: l10n.sentryAnalyticsDescription,
            showSubtitleSkeleton: false,
            value: false,
            enabled: true,
          ),
          ToggleCardSkeleton(
            icon: Icons.videocam_outlined,
            title: l10n.sentryReplay,
            subtitle: l10n.sentryReplayDescription,
            showSubtitleSkeleton: false,
            value: false,
            enabled: false,
          ),
        ],
      ),
      data: (sentryService) => SettingsSection(
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
      ),
    );
  }
}
