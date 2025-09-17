import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

class OtherSection extends ConsumerWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          icon: Icons.favorite_outline,
          title: l10n.contribute,
          subtitle: l10n.contributeDescription,
          onTap: () => _openContribute(context),
        ),
        NavigationCard(
          icon: Icons.share_outlined,
          title: l10n.shareApp,
          subtitle: l10n.shareAppDescription,
          onTap: () => _shareApp(context, ref),
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

  Future<void> _shareApp(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final shareService = ref.read(shareServiceProvider);
      await shareService.shareApp(l10n);
    } catch (e, stackTrace) {
      AppLogger.e('OtherSection: Error sharing app', e, stackTrace);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Text(
            l10n.shareAppError,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openContribute(BuildContext context) async {
    try {
      final Uri contributeUri = Uri.parse(
        'https://github.com/lusu007/dienstplan',
      );
      if (await canLaunchUrl(contributeUri)) {
        await launchUrl(contributeUri);
      }
    } catch (e, stackTrace) {
      AppLogger.e('OtherSection: Error opening contribute link', e, stackTrace);
    }
  }
}
