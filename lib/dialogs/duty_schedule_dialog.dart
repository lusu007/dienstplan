import 'package:flutter/material.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/constants/app_colors.dart';

class DutyScheduleDialog {
  static void show(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDutySchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...provider.configs.map((config) => DialogSelectionCard(
                  title: config.meta.name,
                  subtitle: config.meta.description.isNotEmpty
                      ? config.meta.description
                      : null,
                  isSelected:
                      provider.activeConfig?.meta.name == config.meta.name,
                  onTap: () async {
                    final oldPreferred = provider.preferredDutyGroup;
                    final l10n = AppLocalizations.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    await provider.setActiveConfig(config);
                    navigator.pop();
                    if (oldPreferred != null &&
                        provider.preferredDutyGroup == null) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.preferredDutyGroupResetNotice),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      });
                    }
                  },
                  mainColor: AppColors.primary,
                )),
          ],
        ),
      ),
    );
  }
}
