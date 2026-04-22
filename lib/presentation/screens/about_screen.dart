import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/dialogs/app_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/dialogs/app_license_page.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GlassScreenScaffold(
      title: l10n.about,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoSection(context, l10n),
            const SizedBox(height: 16),
            _buildCreditsSection(context, l10n),
            const SizedBox(height: 16),
            _buildLegalSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, AppLocalizations l10n) {
    final Color subtle = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Image.asset(AppInfo.appIconPath, width: 80, height: 80),
              const SizedBox(height: 16),
              Text(
                AppInfo.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: AppInfo.fullVersion,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          AppInfo.appLegalese,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: subtle),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snapshot.data!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: subtle),
                        ),
                      ],
                    );
                  }
                  return Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.1
                            : 0.28,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.aboutDescription,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: subtle),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.aboutDisclaimer,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: subtle),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCreditsSection(BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.credits,
      cards: [
        NavigationCard(
          icon: Icons.school_outlined,
          title: l10n.visitMehrSchulferien,
          subtitle: l10n.mehrSchulferienCredits,
          onTap: () => _openMehrSchulferien(),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context, AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.legal,
      cards: [
        NavigationCard(
          icon: Icons.warning_outlined,
          title: l10n.disclaimer,
          onTap: () => _showDisclaimerDialog(context),
        ),
        NavigationCard(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          onTap: () => _openPrivacyPolicy(),
        ),
        NavigationCard(
          icon: Icons.description_outlined,
          title: l10n.licenses,
          onTap: () => _showLicenses(context),
        ),
      ],
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.disclaimer,
      content: SingleChildScrollView(child: Text(l10n.disclaimerLong)),
      showCloseButton: true,
    );
  }

  Future<void> _openMehrSchulferien() async {
    final Uri mehrSchulferienUri = Uri.parse(
      'https://www.mehr-schulferien.de/',
    );
    if (await canLaunchUrl(mehrSchulferienUri)) {
      await launchUrl(mehrSchulferienUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri privacyPolicyUri = Uri.parse(AppInfo.privacyPolicyUrl);
    if (await canLaunchUrl(privacyPolicyUri)) {
      await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
    AppLicensePage.show(
      context: context,
      appName: AppInfo.appName,
      appIconPath: AppInfo.appIconPath,
      appLegalese: AppInfo.appLegalese,
    );
  }
}
