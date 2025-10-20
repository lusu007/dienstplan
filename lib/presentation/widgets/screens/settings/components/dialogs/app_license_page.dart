import 'package:flutter/material.dart';

class AppLicensePage extends StatelessWidget {
  final String appName;
  final String? appVersion;
  final String? appIconPath;
  final String? appLegalese;

  const AppLicensePage({
    super.key,
    required this.appName,
    this.appVersion,
    this.appIconPath,
    this.appLegalese,
  });

  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: appIconPath != null
          ? Image.asset(appIconPath!, width: 50, height: 50)
          : null,
      applicationLegalese: appLegalese,
    );
  }

  static void show({
    required BuildContext context,
    required String appName,
    String? appVersion,
    String? appIconPath,
    String? appLegalese,
  }) {
    showLicensePage(
      context: context,
      applicationName: appName,
      applicationVersion: appVersion,
      applicationIcon: appIconPath != null
          ? Image.asset(appIconPath, width: 50, height: 50)
          : null,
      applicationLegalese: appLegalese,
    );
  }
}
