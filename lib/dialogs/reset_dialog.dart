import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/screens/first_time_setup_screen.dart';
import 'package:dienstplan/widgets/dialogs/app_dialog.dart';
import 'package:dienstplan/constants/app_colors.dart';

class ResetDialog {
  static void show(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);

    AppDialog.show(
      context: context,
      title: l10n.resetData,
      content: Text(l10n.resetDataConfirmation),
      showCloseButton: false,
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  // Get the config service before async operations
                  final configService = context.read<ScheduleConfigService>();

                  // Reset the schedule provider
                  await provider.reset();

                  // Reset the setup completion flag
                  await configService.resetSetup();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.resetDataSuccess),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const FirstTimeSetupScreen(),
                      ),
                    );
                  }
                },
                child: Text(l10n.reset),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
