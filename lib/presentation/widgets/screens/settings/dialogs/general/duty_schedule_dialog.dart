import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class DutyScheduleDialog {
  static void show(BuildContext context, ScheduleController controller) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDutySchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...controller.configs.map((config) => SelectionCard(
                  title: config.meta.name,
                  subtitle: config.meta.description.isNotEmpty
                      ? config.meta.description
                      : null,
                  isSelected:
                      controller.activeConfig?.meta.name == config.meta.name,
                  onTap: () async {
                    final oldPreferred = controller.preferredDutyGroup;
                    final l10n = AppLocalizations.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    // Set active config
                    await controller.setActiveConfig(config);

                    // Reset preferred duty group when switching duty plans
                    if (oldPreferred != null) {
                      controller.preferredDutyGroup = null;

                      // Show notification
                      Future.delayed(const Duration(milliseconds: 100), () {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.preferredDutyGroupResetNotice),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      });
                    }

                    navigator.pop();
                  },
                  mainColor: AppColors.primary,
                  useDialogStyle: true,
                )),
          ],
        ),
      ),
    );
  }
}
