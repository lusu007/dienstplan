import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppAboutDialog extends StatelessWidget {
  final String appName;
  final String? appVersion;
  final String? appIconPath;
  final String? appLegalese;
  final List<Widget> children;
  final String? contactEmail;

  const AppAboutDialog({
    super.key,
    required this.appName,
    this.appVersion,
    this.appIconPath,
    this.appLegalese,
    required this.children,
    this.contactEmail,
  });

  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: appIconPath != null
          ? Image.asset(
              appIconPath!,
              width: 50,
              height: 50,
            )
          : null,
      applicationLegalese: appLegalese,
      children: [
        ...children,
        if (contactEmail != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: contactEmail,
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
            child: Text(
              contactEmail!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String appName,
    String? appVersion,
    String? appIconPath,
    String? appLegalese,
    required List<Widget> children,
    String? contactEmail,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final effectiveAppVersion = appVersion ?? packageInfo.version;

    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: appName,
        applicationVersion: effectiveAppVersion,
        applicationIcon: appIconPath != null
            ? Image.asset(
                appIconPath,
                width: 50,
                height: 50,
              )
            : null,
        applicationLegalese: appLegalese,
        children: [
          ...children,
          if (contactEmail != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: contactEmail,
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                }
              },
              child: Text(
                contactEmail,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      );
    }
  }
}
