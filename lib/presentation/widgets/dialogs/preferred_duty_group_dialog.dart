import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class PreferredDutyGroupDialog {
  static void show(BuildContext context, ScheduleController controller) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                ...controller.dutyGroups.map((group) => DialogSelectionCard(
                      title: group,
                      isSelected: controller.preferredDutyGroup == group,
                      onTap: () {
                        controller.preferredDutyGroup = group;
                        Navigator.pop(context);
                      },
                      mainColor: AppColors.primary,
                    )),
                DialogSelectionCard(
                  title: l10n.noPreferredDutyGroup,
                  isSelected: controller.preferredDutyGroup == null,
                  onTap: () {
                    controller.preferredDutyGroup = null;
                    Navigator.pop(context);
                  },
                  mainColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
