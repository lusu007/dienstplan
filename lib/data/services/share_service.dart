import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

/// Service for sharing app content across different platforms
///
/// This service handles sharing the app recommendation with special support
/// for WhatsApp Status. Since WhatsApp Status only accepts media content
/// (images/videos) and not plain text, this service automatically creates
/// a visually appealing image with the share text when sharing.
///
/// Features:
/// - Text-based sharing for most platforms (SMS, Email, etc.)
/// - Image-based sharing for WhatsApp Status compatibility
/// - Automatic fallback mechanisms for error handling
/// - Professional design with app branding
class ShareService {
  static const String _appStoreUrl =
      'https://apps.apple.com/app/dienstplan/id6748340130';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=io.scelus.dienstplan';

  /// Shares the app using the native share functionality
  ///
  /// This will show the native share sheet with all available apps
  /// including WhatsApp, SMS, Email, and other messaging apps.
  /// For WhatsApp Status, it creates an image with the text content
  /// since status updates require media content.
  Future<void> shareApp(AppLocalizations l10n) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String shareText = _buildShareText(packageInfo, l10n);

      // Create an image for WhatsApp Status compatibility
      final imageFile = await _createShareImage(shareText, l10n);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imageFile.path)],
          text: shareText,
          subject: l10n.shareAppSubject,
        ),
      );

      AppLogger.i(
          'ShareService: App shared successfully via native share with image');
    } catch (e, stackTrace) {
      AppLogger.e('ShareService: Error sharing app with image', e, stackTrace);

      // Fallback to text-only sharing
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final String shareText = _buildShareText(packageInfo, l10n);

        await SharePlus.instance.share(
          ShareParams(
            text: shareText,
            subject: l10n.shareAppSubject,
          ),
        );

        AppLogger.i(
            'ShareService: App shared successfully via fallback text share');
      } catch (fallbackError, fallbackStackTrace) {
        AppLogger.e('ShareService: Fallback sharing failed', fallbackError,
            fallbackStackTrace);
        // Last resort: Try to open store directly
        await _openAppStore(l10n);
      }
    }
  }

  /// Opens the app store directly as fallback
  Future<void> openAppStore(AppLocalizations l10n) async {
    await _openAppStore(l10n);
  }

  /// Builds the share text with app information
  String _buildShareText(PackageInfo packageInfo, AppLocalizations l10n) {
    return l10n.shareAppMessage(
      _appStoreUrl,
      _playStoreUrl,
    );
  }

  /// Creates an image with the share text for WhatsApp Status compatibility
  ///
  /// WhatsApp Status only supports media content (images/videos), not plain text.
  /// This method creates a visually appealing image with the share text that can
  /// be shared to WhatsApp Status and other platforms that prefer media content.
  Future<File> _createShareImage(String text, AppLocalizations l10n) async {
    try {
      // Create a canvas to draw the image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Image dimensions optimized for mobile sharing and WhatsApp Status
      const double width = 1080;
      const double height = 1920;

      // Background gradient (police/duty theme colors)
      final backgroundPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, height),
          [
            const Color(0xFF1565C0), // Deep blue
            const Color(0xFF0D47A1), // Darker blue
          ],
        );

      canvas.drawRect(
        const Rect.fromLTWH(0, 0, width, height),
        backgroundPaint,
      );

      // Add app logo area (placeholder circle)
      final logoPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;

      const double logoRadius = 80;
      canvas.drawCircle(
        const Offset(width / 2, height * 0.25),
        logoRadius,
        logoPaint,
      );

      // Add police/duty icon in the logo area
      final iconPaint = Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        const Offset(width / 2, height * 0.25),
        logoRadius * 0.6,
        iconPaint,
      );

      // Add text content
      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            // App title
            const TextSpan(
              text: 'Dienstplan App\n\n',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            // Share message
            TextSpan(
              text: text.replaceAll('Hey! 👋\n\n', '').replaceAll('🚔', ''),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 28,
                height: 1.4,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: null,
      );

      textPainter.layout(maxWidth: width * 0.85);

      // Position text in the center-lower area
      final textOffset = Offset(
        (width - textPainter.width) / 2,
        height * 0.45,
      );

      textPainter.paint(canvas, textOffset);

      // Add decorative elements
      final decorPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw decorative border
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(40, 40, width - 80, height - 80),
          const Radius.circular(20),
        ),
        decorPaint,
      );

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/dienstplan_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      AppLogger.i('ShareService: Share image created successfully');
      return file;
    } catch (e, stackTrace) {
      AppLogger.e('ShareService: Error creating share image', e, stackTrace);
      rethrow;
    }
  }

  /// Opens the appropriate app store based on platform
  Future<void> _openAppStore(AppLocalizations l10n) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Schau dir die Dienstplan App an: $_appStoreUrl',
          subject: l10n.shareAppSubject,
        ),
      );

      AppLogger.i('ShareService: App store shared successfully');
    } catch (e, stackTrace) {
      AppLogger.e('ShareService: Error opening app store', e, stackTrace);
    }
  }
}
