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

  /// Queue for notifications that couldn't be shown immediately
  static final List<_PendingNotification> _pendingNotifications = [];

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
        AppLogger.w(
          'NotificationService: ScaffoldMessenger not available, queuing notification',
        );
        // Queue the notification for later
        _pendingNotifications.add(
          _PendingNotification(
            message: message,
            duration: duration,
            action: action,
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('NotificationService: Error showing snackbar', e, stackTrace);
    }
  }

  /// Process any pending notifications
  void processPendingNotifications() {
    if (_pendingNotifications.isEmpty) return;

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      AppLogger.w(
        'NotificationService: Still no ScaffoldMessenger available for pending notifications',
      );
      return;
    }

    AppLogger.i(
      'NotificationService: Processing ${_pendingNotifications.length} pending notifications',
    );

    for (final pending in _pendingNotifications) {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              pending.message,
              style: pending.textColor != null
                  ? TextStyle(color: pending.textColor)
                  : null,
            ),
            duration: pending.duration,
            action: pending.action,
            backgroundColor: pending.backgroundColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        AppLogger.i(
          'NotificationService: Pending SnackBar displayed: ${pending.message}',
        );
      } catch (e, stackTrace) {
        AppLogger.e(
          'NotificationService: Error showing pending snackbar',
          e,
          stackTrace,
        );
      }
    }

    _pendingNotifications.clear();
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

/// Helper class for pending notifications
class _PendingNotification {
  final String message;
  final Duration duration;
  final SnackBarAction? action;
  final Color? backgroundColor;
  final Color? textColor;

  _PendingNotification({
    required this.message,
    required this.duration,
    this.action,
    this.backgroundColor,
    this.textColor,
  });
}
