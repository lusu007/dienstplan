import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/schedule_day_filtering.dart';

class SchedulesBottomSheet extends ConsumerStatefulWidget {
  final DateTime day;

  const SchedulesBottomSheet({super.key, required this.day});

  static Future<void> show(BuildContext context, DateTime day) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return SchedulesBottomSheet(day: day);
      },
    ).then((void _) {
      if (!context.mounted) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  @override
  ConsumerState<SchedulesBottomSheet> createState() =>
      _SchedulesBottomSheetState();
}

class _SchedulesBottomSheetState extends ConsumerState<SchedulesBottomSheet> {
  DateTime? _currentDay;
  bool _isDayUpdateInFlight = false;
  int _pendingDayDelta = 0;

  DateTime get _resolvedCurrentDay => _currentDay ?? widget.day;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.day;
  }

  Future<void> _queueDayDeltaUpdate(int dayDelta) async {
    _pendingDayDelta += dayDelta;
    await _flushPendingDayDeltaUpdates();
  }

  Future<void> _flushPendingDayDeltaUpdates() async {
    if (_isDayUpdateInFlight) {
      return;
    }
    _isDayUpdateInFlight = true;
    while (mounted && _pendingDayDelta != 0) {
      final int step = _pendingDayDelta.isNegative ? -1 : 1;
      _pendingDayDelta -= step;
      await _updateCurrentDayByDelta(step);
    }
    _isDayUpdateInFlight = false;
  }

  Future<void> _updateCurrentDayByDelta(int dayDelta) async {
    final DateTime currentDay = _resolvedCurrentDay;
    final DateTime nextDay = currentDay.isUtc
        ? DateTime.utc(
            currentDay.year,
            currentDay.month,
            currentDay.day + dayDelta,
          )
        : DateTime(
            currentDay.year,
            currentDay.month,
            currentDay.day + dayDelta,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _currentDay = nextDay;
    });
    final ScheduleCoordinatorNotifier notifier = ref.read(
      scheduleCoordinatorProvider.notifier,
    );
    await notifier.setSelectedDay(nextDay);
    await notifier.setFocusedDay(nextDay);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScheduleUiState? state = ref.watch(
      scheduleCoordinatorProvider.select(
        (AsyncValue<ScheduleUiState> s) => s.value,
      ),
    );
    final DateTime currentDay = _resolvedCurrentDay;
    final List<Schedule> schedulesForDay = filterSchedulesForSingleDay(
      state?.schedules,
      currentDay,
    );
    final bool hasSchedulesForDay = schedulesForDay.isNotEmpty;
    final bool isLoadingSelectedDay =
        (state?.isLoading ?? false) && !hasSchedulesForDay;
    schedulePostFrameEnsureDayIfEmpty(
      ref: ref,
      context: context,
      day: currentDay,
      hasSchedulesForDay: hasSchedulesForDay,
      isLoadingSelectedDay: isLoadingSelectedDay,
      activeConfigName: state?.activeConfigName,
    );
    return GlassBottomSheet(
      showHandleBar: true,
      heightPercentage: 0.72,
      children: <Widget>[
        _SheetHeader(day: currentDay, l10n: l10n),
        Expanded(
          child: _HorizontalDaySwipeListener(
            onSwipeLeft: () {
              unawaited(_queueDayDeltaUpdate(1));
            },
            onSwipeRight: () {
              unawaited(_queueDayDeltaUpdate(-1));
            },
            child: ScrollFadeMask(
              child: DutyScheduleList(
                schedules: schedulesForDay,
                activeConfigName: state?.activeConfigName,
                dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
                dutyTypes: state?.activeConfig?.dutyTypes,
                shouldAnimate: false,
                isLoading: isLoadingSelectedDay,
                selectedDay: currentDay,
                visualStyle: DutyListVisualStyle.glassCompact,
                topPadding: glassSpacingXl,
                bottomPadding: glassSpacingLg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalDaySwipeListener extends StatefulWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final Widget child;

  const _HorizontalDaySwipeListener({
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.child,
  });

  @override
  State<_HorizontalDaySwipeListener> createState() =>
      _HorizontalDaySwipeListenerState();
}

class _HorizontalDaySwipeListenerState
    extends State<_HorizontalDaySwipeListener> {
  static const double _distanceThreshold = 56.0;
  double _dx = 0;
  double _dy = 0;

  void _reset() {
    _dx = 0;
    _dy = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        _reset();
      },
      onPointerMove: (PointerMoveEvent event) {
        _dx += event.delta.dx;
        _dy += event.delta.dy;
      },
      onPointerUp: (_) {
        _onPointerEnd();
      },
      onPointerCancel: (_) {
        _onPointerEnd();
      },
      child: widget.child,
    );
  }

  void _onPointerEnd() {
    final bool isHorizontalDominant = _dx.abs() >= _dy.abs() * 1.15;
    if (!isHorizontalDominant) {
      _reset();
      return;
    }
    if (_dx <= -_distanceThreshold) {
      widget.onSwipeLeft();
    } else if (_dx >= _distanceThreshold) {
      widget.onSwipeRight();
    }
    _reset();
  }
}

class _SheetHeader extends ConsumerWidget {
  final DateTime day;
  final AppLocalizations l10n;

  const _SheetHeader({required this.day, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String localeName = Localizations.localeOf(context).toString();
    final String weekday = DateFormat(
      'EEEE',
      localeName,
    ).format(day).toUpperCase();
    final String monthYear = DateFormat('MMMM yyyy', localeName).format(day);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isToday = _isSameDay(day, DateTime.now());
    final bool showOtherDutyGroups = ref.watch(
      settingsProvider.select(
        (AsyncValue<SettingsUiState> s) =>
            s.value?.showOtherDutyGroupsInCompactList ?? false,
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        glassSpacingXl - 4,
        glassSpacingMd,
        glassSpacingXl - 4,
        glassSpacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(width: glassSpacingMd),
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
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 0),
                Text(
                  monthYear,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isToday) ...<Widget>[
            const SizedBox(width: glassSpacingSm),
            _TodayPill(label: l10n.today),
          ],
          const SizedBox(width: glassSpacingSm),
          GlassIconToggleChip(
            tooltip: showOtherDutyGroups
                ? l10n.compactListHideOtherDutyGroupsTooltip
                : l10n.compactListShowOtherDutyGroupsTooltip,
            isSelected: showOtherDutyGroups,
            selectedIcon: Icons.visibility_rounded,
            unselectedIcon: Icons.visibility_off_rounded,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setShowOtherDutyGroupsInCompactList(!showOtherDutyGroups);
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime firstDate, DateTime secondDate) {
    return firstDate.year == secondDate.year &&
        firstDate.month == secondDate.month &&
        firstDate.day == secondDate.day;
  }
}

class _TodayPill extends StatelessWidget {
  final String label;

  const _TodayPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: glassSpacingMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.38 : 0.3),
        borderRadius: BorderRadius.circular(glassSurfaceRadiusPill),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: isDark ? glassBorderAlphaDark : glassBorderAlphaLight,
          ),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
