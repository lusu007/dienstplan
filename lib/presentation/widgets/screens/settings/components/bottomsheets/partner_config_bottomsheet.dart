import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';

class PartnerConfigBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final ProviderContainer container = ProviderScope.containerOf(
      context,
      listen: false,
    );
    final AppLocalizations l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext dialogContext) => Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final ScheduleUiState? state = ref.watch(
            scheduleCoordinatorProvider.select(
              (AsyncValue<ScheduleUiState> s) => s.value,
            ),
          );
          final List<DutyScheduleConfig> configs = state?.configs ?? const [];
          final DateTime? initialFocused = state?.focusedDay;

          if (configs.isEmpty) {
            return GlassBottomSheet(
              title: l10n.partnerDutySchedule,
              shrinkToContent: true,
              children: <Widget>[
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
            heightPercentage: heightPercentage,
            onConfigSelected: (DutyScheduleConfig? config) async {
              final notifier = ref.read(scheduleCoordinatorProvider.notifier);
              if (config != null) {
                await notifier.setPartnerConfigName(config.name);
                await notifier.setPartnerDutyGroup(null);
                if (initialFocused != null) {
                  await notifier.setFocusedDay(initialFocused);
                }
              } else {
                await notifier.setPartnerConfigName(null);
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
