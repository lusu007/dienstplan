import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/dialogs/app_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/dialogs/app_license_page.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/safe_area_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: SafeAreaWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Info Section
              _buildAppInfoSection(context, l10n),
              const SizedBox(height: 16),

              // Credits Section
              _buildCreditsSection(context, l10n),
              const SizedBox(height: 16),

              // Legal Section
              _buildLegalSection(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Icon and Name
        Center(
          child: Column(
            children: [
              Image.asset(AppInfo.appIconPath, width: 80, height: 80),
              const SizedBox(height: 16),
              Text(
                AppInfo.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snapshot.data!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    );
                  }
                  return Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // About Description
        Text(
          l10n.aboutDescription,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Disclaimer
        Text(
          l10n.aboutDisclaimer,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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
