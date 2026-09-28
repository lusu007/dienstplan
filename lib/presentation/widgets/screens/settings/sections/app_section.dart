import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';

class AppSection extends ConsumerWidget {
  const AppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.app,
      cards: [
        NavigationCard(
          icon: Icons.new_releases_outlined,
          title: l10n.settingsWhatsNewShowAgain,
          subtitle: l10n.settingsWhatsNewShowAgainSubtitle,
          onTap: () => showWhatsNewDialog(context),
        ),
        NavigationCard(
          modalTrigger: true,
          icon: Icons.delete_forever_outlined,
          title: l10n.resetData,
          onTap: () => ResetBottomsheet.show(context),
          iconColor: AppColors.destructiveIconBadgeTint,
        ),
      ],
    );
  }
}
