import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class ShareService {
  static const String _appStoreUrl =
      'https://apps.apple.com/app/dienstplan/id123456789';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.scelus.dienstplan';

  /// Shares the app using the native share functionality
  ///
  /// This will show the native share sheet with all available apps
  /// including WhatsApp, SMS, Email, and other messaging apps
  static Future<void> shareApp(AppLocalizations l10n) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final shareText = _buildShareText(packageInfo, l10n);

      await Share.share(
        shareText,
        subject: l10n.shareAppSubject,
      );

      AppLogger.i('ShareService: App shared successfully via native share');
    } catch (e, stackTrace) {
      AppLogger.e('ShareService: Error sharing app', e, stackTrace);
      // Fallback: Try to open store directly
      await _openAppStore(l10n);
    }
  }

  /// Opens the app store directly as fallback
  static Future<void> openAppStore(AppLocalizations l10n) async {
    await _openAppStore(l10n);
  }

  /// Builds the share text with app information
  static String _buildShareText(
      PackageInfo packageInfo, AppLocalizations l10n) {
    return l10n.shareAppMessage(
      _appStoreUrl,
      _playStoreUrl,
    );
  }

  /// Opens the appropriate app store based on platform
  static Future<void> _openAppStore(AppLocalizations l10n) async {
    try {
      await Share.share(
        'Schau dir die Dienstplan App an: $_appStoreUrl',
        subject: l10n.shareAppSubject,
      );

      AppLogger.i('ShareService: App store shared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('ShareService: Error opening app store', e, stackTrace);
    }
  }
}
