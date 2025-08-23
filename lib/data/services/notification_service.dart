import 'package:flutter/material.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

/// Service for displaying notifications and messages to the user
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Global key for accessing ScaffoldMessenger from anywhere in the app
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show a snackbar notification
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
  }) {
    try {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: textColor != null ? TextStyle(color: textColor) : null,
            ),
            duration: duration,
            action: action,
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        AppLogger.i('NotificationService: SnackBar displayed: $message');
      } else {
        AppLogger.w('NotificationService: ScaffoldMessenger not available');
      }
    } catch (e, stackTrace) {
      AppLogger.e('NotificationService: Error showing snackbar', e, stackTrace);
    }
  }

  /// Show a notification about schedule updates
  void showScheduleUpdateNotification({
    required String configName,
    required String oldVersion,
    required String newVersion,
    required AppLocalizations l10n,
  }) {
    final message = l10n.scheduleUpdateNotification(
      configName,
      oldVersion,
      newVersion,
    );

    showSnackBar(
      message: message,
      duration: const Duration(seconds: 6),
      backgroundColor: Colors.blue.shade100,
      textColor: Colors.blue.shade900,
    );
  }

  /// Show a notification about multiple schedule updates
  void showMultipleScheduleUpdatesNotification({
    required List<String> configNames,
    required AppLocalizations l10n,
  }) {
    final configList = configNames.join(', ');
    final message = l10n.multipleScheduleUpdatesNotification(configList);

    showSnackBar(
      message: message,
      duration: const Duration(seconds: 8),
      backgroundColor: Colors.orange.shade100,
      textColor: Colors.orange.shade900,
    );
  }
}
