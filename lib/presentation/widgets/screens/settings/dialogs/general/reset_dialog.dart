import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Accessed via riverpod provider
import 'package:dienstplan/core/l10n/app_localizations.dart';
// ignore: unused_import
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/legal/app_dialog.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

class ResetDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.resetData,
      content: Text(l10n.resetDataConfirmation),
      showCloseButton: false,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: () async {
              final container =
                  ProviderScope.containerOf(context, listen: false);
              final configService =
                  await container.read(scheduleConfigServiceProvider.future);

              await configService.resetSetup();
              await container.read(settingsProvider.notifier).reset();

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    content: Text(
                      l10n.resetDataSuccess,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.router.replaceAll([const SetupRoute()]);
              }
            },
            child: Text(l10n.reset),
          ),
        ),
      ],
    );
  }
}
