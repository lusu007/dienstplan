import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';

class PartnerConfigBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final l10n = AppLocalizations.of(context);

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
          final configs = state?.configs ?? const [];

          if (configs.isEmpty) {
            return GlassBottomSheet(
              title: l10n.partnerDutySchedule,
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
                    l10n.noDutySchedules,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }

          return ConfigSelectionBottomsheet(
            title: l10n.partnerDutySchedule,
            configs: configs,
            selectedConfigName: state?.partnerConfigName,
            onConfigSelected: (config) async {
              if (config != null) {
                // Perform operations after dialog is closed
                await notifier.setPartnerConfigName(config.name);
                // Reset partner duty group when duty plan changes
                await notifier.setPartnerDutyGroup(null);
                if (initialFocused != null) {
                  await notifier.setFocusedDay(initialFocused);
                }
              } else {
                // Perform operations after dialog is closed
                await notifier.setPartnerConfigName(null);
                // Reset partner duty group when duty plan is cleared
                await notifier.setPartnerDutyGroup(null);
                if (initialFocused != null) {
                  await notifier.setFocusedDay(initialFocused);
                }
              }
            },
          );
        },
      ),
    );
    await container
        .read(scheduleCoordinatorProvider.notifier)
        .applyPartnerSelectionChanges();
  }
}
