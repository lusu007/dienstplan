import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static const String appName = 'Dienstplan';
  static const String appIconPath = 'assets/images/logo.png';
  static const String contactEmail = 'hi@scelus.io';
  static const String privacyPolicyUrl =
      'https://assets.scelus.io/datenschutz.html';

  static String get appLegalese =>
      '© ${DateTime.now().year} Scelus Development (Lukas Jost)';

  static Future<String> get fullVersion async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version}+${packageInfo.buildNumber}';
  }
}
