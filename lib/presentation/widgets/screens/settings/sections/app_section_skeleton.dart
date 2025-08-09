import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card_skeleton.dart';

class AppSectionSkeleton extends StatelessWidget {
  const AppSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.app,
      cards: const [
        NavigationCardSkeleton(
          icon: Icons.language_outlined,
          title: 'Language',
          showSubtitleSkeleton: false,
        ),
        NavigationCardSkeleton(
          icon: Icons.delete_forever_outlined,
          title: 'Reset Data',
          showSubtitleSkeleton: false,
        ),
      ],
    );
  }
}
