import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/screens/contact_feedback_screen.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';

/// In-app contact with Sentry feedback.
class ContactFeedbackService {
  const ContactFeedbackService._();

  static Future<void> openContact({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final service = await ref.read(sentryServiceProvider.future);
      if (!context.mounted) {
        return;
      }
      if (service.isEnabled) {
        await _showContactFeedbackScreen(context);
        return;
      }
      await _showSentryDisabledHint(context: context, ref: ref);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to open contact feedback '
        '(screen=settings_contact, errorType=${e.runtimeType})',
        e,
        stackTrace,
      );
    }
  }

  static Future<void> _showContactFeedbackScreen(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const ContactFeedbackScreen(),
      ),
    );
  }

  static Future<void> _showSentryDisabledHint({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!context.mounted) {
      return;
    }
    await GlassAppDialog.show<void>(
      context: context,
      title: l10n.contactDisabledFeedbackTitle,
      content: Text(l10n.contactDisabledFeedbackDescription),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final service = await ref.read(sentryServiceProvider.future);
              await service.setEnabled(true);
              ref.invalidate(sentryStateProvider);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              await _showContactFeedbackScreen(context);
            },
            child: Text(l10n.contactDisabledFeedbackEnable),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.contactDisabledFeedbackCancel),
          ),
        ),
      ],
    );
  }
}
