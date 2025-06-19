import 'package:flutter/material.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/widgets/dialogs/dialog_close_button.dart';
import 'package:dienstplan/constants/app_colors.dart';

class PreferredDutyGroupDialog {
  static void show(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectPreferredDutyGroup),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...provider.dutyGroups.map((group) => DialogSelectionCard(
                            title: group,
                            isSelected: provider.preferredDutyGroup == group,
                            onTap: () {
                              provider.preferredDutyGroup = group;
                              Navigator.pop(context);
                            },
                            mainColor: AppColors.primary,
                          )),
                      DialogSelectionCard(
                        title: l10n.noPreferredDutyGroup,
                        isSelected: provider.preferredDutyGroup == null,
                        onTap: () {
                          provider.preferredDutyGroup = null;
                          Navigator.pop(context);
                        },
                        mainColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          const DialogCloseButton(mainColor: AppColors.primary),
        ],
      ),
    );
  }
}
