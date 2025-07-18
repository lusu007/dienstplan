import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class PreferredDutyGroupDialog {
  static void show(BuildContext context, ScheduleController controller) {
    final l10n = AppLocalizations.of(context);

    // Validate controller state before showing dialog
    if (controller.activeConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active duty schedule selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          // Get current duty groups from the active config
          final dutyGroups = controller.activeConfig?.dutyGroups
                  .map((group) => group.name)
                  .toList() ??
              [];

          // If no duty groups available, show message
          if (dutyGroups.isEmpty) {
            return AlertDialog(
              title: Text(l10n.selectPreferredDutyGroup),
              content: const Text(
                  'No duty groups available in the current schedule.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text(l10n.selectPreferredDutyGroup),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                minHeight: 200,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...dutyGroups.map((group) => SelectionCard(
                          title: group,
                          isSelected: controller.preferredDutyGroup == group,
                          onTap: () {
                            controller.preferredDutyGroup = group;
                            Navigator.pop(context);
                          },
                          mainColor: AppColors.primary,
                          useDialogStyle: true,
                        )),
                    SelectionCard(
                      title: l10n.noPreferredDutyGroup,
                      isSelected: controller.preferredDutyGroup == null,
                      onTap: () {
                        controller.preferredDutyGroup = null;
                        Navigator.pop(context);
                      },
                      mainColor: AppColors.primary,
                      useDialogStyle: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
