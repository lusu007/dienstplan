import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart';

class MyDutyGroupBottomsheet {
  static void show(BuildContext context, {double? heightPercentage}) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(scheduleCoordinatorProvider);
          final state = asyncState.value;
          final dutyGroups = state?.dutyGroups ?? const <String>[];

          if ((state?.activeConfigName ?? '').isEmpty) {
            return GlassBottomSheet(
              title: l10n.selectMyDutyGroup,
              shrinkToContent: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    glassSpacingXl,
                    glassSpacingMd,
                    glassSpacingXl,
                    glassSpacingXl,
                  ),
                  child: Text(
                    l10n.selectMyDutyScheduleFirst,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }

          return DutyGroupSelectionBottomsheet(
            title: l10n.myDutyGroup,
            dutyGroups: dutyGroups,
            selectedDutyGroup: state?.preferredDutyGroup,
            heightPercentage: heightPercentage,
            onDutyGroupSelected: (group) async {
              await ref
                  .read(scheduleCoordinatorProvider.notifier)
                  .setPreferredDutyGroup(group ?? '');
            },
          );
        },
      ),
    );
  }
}
