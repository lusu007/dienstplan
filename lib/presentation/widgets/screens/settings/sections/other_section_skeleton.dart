import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card_skeleton.dart';

class OtherSectionSkeleton extends StatelessWidget {
  const OtherSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
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
}
