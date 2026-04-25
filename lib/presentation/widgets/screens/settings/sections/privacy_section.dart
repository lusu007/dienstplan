import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card_skeleton.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final sentryStateAsync = ref.watch(sentryStateProvider);

    return sentryStateAsync.when(
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
      error: (e, st) {
        AppLogger.e('PrivacySection: sentryStateProvider failed', e, st);
        return SettingsSection(
          title: l10n.privacy,
          cards: [
            NavigationCard(
              icon: Icons.error_outline_rounded,
              title: l10n.errorLoading,
              subtitle: l10n.tryAgain,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => ref.invalidate(sentryStateProvider),
            ),
            const SizedBox(height: glassSpacingXs),
          ],
        );
      },
      data: (sentryState) => SettingsSection(
        title: l10n.privacy,
        cards: [
          ToggleCard(
            icon: Icons.analytics_outlined,
            title: l10n.sentryAnalytics,
            subtitle: l10n.sentryAnalyticsDescription,
            value: sentryState.isEnabled,
            onChanged: (value) => _handleAnalyticsToggle(ref, value),
          ),
          ToggleCard(
            icon: Icons.videocam_outlined,
            title: l10n.sentryReplay,
            subtitle: l10n.sentryReplayDescription,
            value: sentryState.isReplayEnabled,
            enabled: sentryState.isEnabled,
            onChanged: sentryState.isEnabled
                ? (value) => _handleReplayToggle(ref, value)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAnalyticsToggle(WidgetRef ref, bool value) async {
    final service = await ref.read(sentryServiceProvider.future);
    await service.setEnabled(value);
    // Invalidate the state provider to trigger a rebuild
    ref.invalidate(sentryStateProvider);
  }

  Future<void> _handleReplayToggle(WidgetRef ref, bool value) async {
    final service = await ref.read(sentryServiceProvider.future);
    await service.setReplayEnabled(value);
    // Invalidate the state provider to trigger a rebuild
    ref.invalidate(sentryStateProvider);
  }
}
