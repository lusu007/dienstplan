import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/schedule_day_filtering.dart';

/// In-layout day list: same data as [SchedulesDialog], glass look with
/// compact typography to match the split calendar.
class DaySchedulesListPanel extends ConsumerWidget {
  const DaySchedulesListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final DateTime day = state?.selectedDay ?? DateTime.now();
    final forDay = filterSchedulesForSingleDay(state?.schedules, day);
    final bool hasForDay = forDay.isNotEmpty;
    final bool isLoadingSelectedDay = (state?.isLoading ?? false) && !hasForDay;

    schedulePostFrameEnsureDayIfEmpty(
      ref: ref,
      context: context,
      day: day,
      hasSchedulesForDay: hasForDay,
      isLoadingSelectedDay: isLoadingSelectedDay,
      activeConfigName: state?.activeConfigName,
    );

    return Column(
      children: <Widget>[
        _CompactDayHeader(day: day),
        Expanded(
          child: ScrollFadeMask(
            topFadeFraction: 0.03,
            bottomFadeFraction: 0.06,
            child: DutyScheduleList(
              schedules: forDay,
              activeConfigName: state?.activeConfigName,
              dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
              dutyTypes: state?.activeConfig?.dutyTypes,
              shouldAnimate: false,
              isLoading: isLoadingSelectedDay,
              selectedDay: day,
              visualStyle: DutyListVisualStyle.glassCompact,
              topPadding: 4,
              bottomPadding: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactDayHeader extends ConsumerWidget {
  final DateTime day;

  const _CompactDayHeader({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Locale locale = Localizations.localeOf(context);
    final String localeName = locale.toString();
    final String weekday = DateFormat(
      'EEEE',
      localeName,
    ).format(day).toUpperCase();
    final String monthYear = DateFormat('MMMM yyyy', localeName).format(day);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool showOtherDutyGroups = ref.watch(
      settingsProvider.select(
        (AsyncValue<SettingsUiState> s) =>
            s.value?.showOtherDutyGroupsInCompactList ?? false,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: <Widget>[
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  weekday,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  monthYear,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: showOtherDutyGroups
                ? l10n.compactListHideOtherDutyGroupsTooltip
                : l10n.compactListShowOtherDutyGroupsTooltip,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setShowOtherDutyGroupsInCompactList(
                        !showOtherDutyGroups,
                      );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: showOtherDutyGroups
                        ? colorScheme.primary.withValues(alpha: 0.28)
                        : Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: showOtherDutyGroups
                          ? colorScheme.primary.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.32),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    showOtherDutyGroups
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 20,
                    color: showOtherDutyGroups
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
