import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart';

class PartnerGroupBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);

    // Safety check: prevent dialog from opening if no partner duty plan is selected
    final state = container.read(scheduleCoordinatorProvider).value;
    if (state?.partnerConfigName == null || state!.partnerConfigName!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectPartnerDutyScheduleFirst),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(scheduleCoordinatorProvider).value;
          final notifier = ref.read(scheduleCoordinatorProvider.notifier);
          final DateTime? initialFocused = state?.focusedDay;
          final l10n = AppLocalizations.of(context);
          final String? selectedConfigName = state?.partnerConfigName;
          final groupsForSelected = (state?.configs ?? const [])
              .where((c) => c.name == selectedConfigName)
              .expand((c) => c.dutyGroups.map((g) => g.name))
              .toList();

          if (selectedConfigName == null || selectedConfigName.isEmpty) {
            return GlassBottomSheet(
              title: l10n.partnerDutyGroup,
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
                    l10n.selectPartnerDutyScheduleFirst,
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
            title: l10n.partnerDutyGroup,
            dutyGroups: groupsForSelected,
            selectedDutyGroup: state?.partnerDutyGroup,
            heightPercentage: heightPercentage,
            onDutyGroupSelected: (group) async {
              await notifier.setPartnerDutyGroup(group);
              if (initialFocused != null) {
                await notifier.setFocusedDay(initialFocused);
              }
            },
          );
        },
      ),
    );
    // After dialog is dismissed (tap outside/back), apply heavy loads once
    await container
        .read(scheduleCoordinatorProvider.notifier)
        .applyPartnerSelectionChanges();
  }
}
