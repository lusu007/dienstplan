import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/toggle_card_skeleton.dart';

class PrivacySectionSkeleton extends StatelessWidget {
  const PrivacySectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.privacy,
      cards: const [
        ToggleCardSkeleton(
          icon: Icons.analytics_outlined,
          title: 'Sentry Analytics',
          subtitle: 'Anonymous error analytics',
          showSubtitleSkeleton: false,
          value: false,
          enabled: true,
        ),
        ToggleCardSkeleton(
          icon: Icons.videocam_outlined,
          title: 'Sentry Replay',
          subtitle: 'Session replay',
          showSubtitleSkeleton: false,
          value: false,
          enabled: false,
        ),
      ],
    );
  }
}
