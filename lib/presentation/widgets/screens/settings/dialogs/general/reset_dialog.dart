import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/legal/app_dialog.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:get_it/get_it.dart';

class ResetDialog {
  static void show(BuildContext context, ScheduleController controller) {
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
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: () async {
              // Get the config service before async operations
              final configService = GetIt.instance<ScheduleConfigService>();

              // Reset the setup completion flag
              await configService.resetSetup();

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                // Zeige Snackbar nach dem Pop
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.resetDataSuccess),
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SetupScreen(),
                  ),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ),
      ],
    );
  }
}
