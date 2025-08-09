import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/data/services/share_service.dart';

class OtherSection extends StatelessWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.other,
      cards: [
        NavigationCard(
          icon: Icons.info_outline,
          title: l10n.about,
          onTap: () => context.router.push(const AboutRoute()),
        ),
        NavigationCard(
          icon: Icons.email_outlined,
          title: l10n.contact,
          subtitle: l10n.contactDescription,
          onTap: () => _openContact(context),
        ),
        NavigationCard(
          icon: Icons.share_outlined,
          title: l10n.shareApp,
          subtitle: l10n.shareAppDescription,
          onTap: () => _shareApp(context),
        ),
      ],
    );
  }

  Future<void> _openContact(BuildContext context) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: AppInfo.contactEmail,
      );
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e, stackTrace) {
      AppLogger.e('OtherSection: Error opening contact email', e, stackTrace);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ShareService.shareApp(l10n);
    } catch (e, stackTrace) {
      AppLogger.e('OtherSection: Error sharing app', e, stackTrace);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareAppError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
