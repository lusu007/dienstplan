import 'package:dienstplan/presentation/widgets/common/app_glass_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_sheet_backdrop.dart'
    show GlassSheetScope, GlassSheetSession;
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedule_load_status.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/schedule_day_filtering.dart';

class SchedulesBottomSheet extends ConsumerStatefulWidget {
  final DateTime day;

  const SchedulesBottomSheet({super.key, required this.day});

  static Future<void> show(BuildContext context, DateTime day) {
    return showAppGlassBottomSheet<void>(
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
  // Enough room before the initial day without constructing offscreen pages.
  static const _initialPage = 365000;
  late final PageController _pageController;
  int _settledPage = _initialPage;
  int? _buttonTarget;
  final _paging = ValueNotifier(false);
  DateTime? _pendingSelection;
  bool _updatingSelection = false;
  GlassSheetSession? _backdropSession;
  Timer? _backdropTimer;
  bool _needsBackdropRefresh = false;

  DateTime _dayForPage(int page) {
    final day = widget.day;
    return day.isUtc
        ? DateTime.utc(day.year, day.month, day.day + page - _initialPage)
        : DateTime(day.year, day.month, day.day + page - _initialPage);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _backdropTimer?.cancel();
    _paging.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigate(int delta) {
    final target = (_buttonTarget ?? _pageController.page!.round()) + delta;
    if (target < 0) return;
    _buttonTarget = target;
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      _pageController.jumpToPage(target);
      _commitPage(target);
    } else {
      unawaited(
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  void _commitPage(int page) {
    _buttonTarget = null;
    if (_settledPage == page) return;
    setState(() => _settledPage = page);
    _pendingSelection = _dayForPage(page);
    unawaited(_flushSelection());
  }

  Future<void> _flushSelection() async {
    if (_updatingSelection) return;
    _updatingSelection = true;
    final notifier = ref.read(scheduleCoordinatorProvider.notifier);
    try {
      // Complete the latest committed selection even if the sheet closes while
      // an earlier month is loading. No widget state is touched after await.
      while (_pendingSelection != null) {
        final day = _pendingSelection!;
        _pendingSelection = null;
        await notifier.selectFocusedDay(selectedDay: day, focusedDay: day);
      }
    } finally {
      _updatingSelection = false;
    }
  }

  void _scheduleBackdropRefresh() {
    _backdropTimer?.cancel();
    if (_paging.value || !_needsBackdropRefresh || _backdropSession == null) {
      return;
    }
    // Coalesce quick reversals and keep image readback out of the gesture.
    _backdropTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _needsBackdropRefresh = false;
      unawaited(_backdropSession!.refresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    _backdropSession = GlassSheetScope.maybeOf(context);
    ref.listen(
      scheduleCoordinatorProvider.select(
        (state) => (state.value?.selectedDay, state.value?.focusedDay),
      ),
      (_, _) {
        _needsBackdropRefresh = true;
        _scheduleBackdropRefresh();
      },
    );
    final day = _dayForPage(_settledPage);
    return GlassBottomSheet(
      showHandleBar: true,
      heightPercentage: 0.72,
      fadeScrollEdges: false,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compactHeader =
                constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: compactHeader ? 56 : 0),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      // Ignore the vertical list's notifications. Only settled
                      // horizontal pages update selection or trigger loading.
                      if (notification.depth == 0) {
                        if (notification is ScrollStartNotification) {
                          _paging.value = true;
                          _backdropTimer?.cancel();
                        } else if (notification is ScrollEndNotification) {
                          _paging.value = false;
                          _commitPage(_pageController.page!.round());
                          _scheduleBackdropRefresh();
                        }
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemBuilder: (context, page) {
                        final pageDay = _dayForPage(page);
                        return RepaintBoundary(
                          child: _DayPage(
                            key: ValueKey(pageDay),
                            day: pageDay,
                            isSelected: page == _settledPage,
                            compactHeader: compactHeader,
                            paging: _paging,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: compactHeader ? null : 4,
                  bottom: compactHeader ? 0 : null,
                  left: 4,
                  right: 4,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _paging,
                    builder: (context, paging, _) => _SheetControls(
                      day: day,
                      paging: paging,
                      onPrevious: () => _navigate(-1),
                      onNext: () => _navigate(1),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DayPage extends ConsumerStatefulWidget {
  const _DayPage({
    super.key,
    required this.day,
    required this.isSelected,
    required this.compactHeader,
    required this.paging,
  });
  final DateTime day;
  final bool isSelected;
  final bool compactHeader;
  final ValueNotifier<bool> paging;

  @override
  ConsumerState<_DayPage> createState() => _DayPageState();
}

class _DayPageState extends ConsumerState<_DayPage> {
  final _ensureSelectedDay = EnsureSelectedDayPostFrame();
  // Keep the list mounted when its fade is toggled; switching a mask must not
  // recreate cards or reset a user's vertical scroll position.
  final _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(scheduleCoordinatorProvider);
    final state = asyncState.value;
    final schedules = filterSchedulesForSingleDay(
      state?.schedules,
      widget.day,
      activeConfigName: state?.activeConfigName,
      partnerConfigName: state?.partnerConfigName,
    );
    final isLoading =
        (asyncState.isLoading || (state?.isLoading ?? false)) &&
        schedules.isEmpty;
    final error = scheduleLoadErrorMessage(context, asyncState);
    if (widget.isSelected) {
      _ensureSelectedDay.scheduleIfEmpty(
        ref: ref,
        context: context,
        day: widget.day,
        hasSchedulesForDay: schedules.isNotEmpty,
        isLoadingSelectedDay: isLoading,
        activeConfigName: error == null ? state?.activeConfigName : null,
      );
    }
    return Column(
      children: [
        _SheetHeader(
          day: widget.day,
          l10n: AppLocalizations.of(context),
          compact: widget.compactHeader,
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.paging,
            child: ScheduleLoadStatus(
              key: _listKey,
              isLoading: asyncState.isLoading || (state?.isLoading ?? false),
              errorMessage: error,
              hasVisibleSchedules: schedules.isNotEmpty,
              onRetry: () => ref
                  .read(scheduleCoordinatorProvider.notifier)
                  .retryFailedLoad(),
              child: DutyScheduleList(
                key: PageStorageKey(widget.day),
                schedules: schedules,
                activeConfigName: state?.activeConfigName,
                dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
                dutyTypes: state?.activeConfig?.dutyTypes,
                shouldAnimate: false,
                isLoading: isLoading,
                selectedDay: widget.day,
                visualStyle: DutyListVisualStyle.glassCompact,
                topPadding: glassSpacingXl,
                bottomPadding: glassSpacingLg,
              ),
            ),
            builder: (context, paging, child) => ScrollFadeMask(
              enabled: !paging,
              deferDuringSheetTransition: true,
              child: child!,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetControls extends ConsumerWidget {
  const _SheetControls({
    required this.day,
    required this.onPrevious,
    required this.onNext,
    required this.paging,
  });
  final DateTime day;
  final bool paging;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final showOtherDutyGroups = ref.watch(
      settingsProvider.select(
        (state) => state.value?.showOtherDutyGroupsInCompactList ?? false,
      ),
    );
    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousDayTooltip,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        const Spacer(),
        IconButton(
          tooltip: l10n.nextDayTooltip,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        GlassIconToggleChip(
          isEnabled: !paging,
          tooltip: l10n.addPersonalEntryTooltip,
          isSelected: false,
          selectedIcon: Icons.add_rounded,
          unselectedIcon: Icons.add_rounded,
          onTap: () => showPersonalCalendarEntrySheet(
            context: context,
            ref: ref,
            day: day,
            existingSchedule: null,
          ),
        ),
        const SizedBox(width: glassSpacingSm),
        GlassIconToggleChip(
          isEnabled: !paging,
          tooltip: showOtherDutyGroups
              ? l10n.compactListHideOtherDutyGroupsTooltip
              : l10n.compactListShowOtherDutyGroupsTooltip,
          isSelected: showOtherDutyGroups,
          selectedIcon: Icons.visibility_rounded,
          unselectedIcon: Icons.visibility_off_rounded,
          onTap: () => ref
              .read(settingsProvider.notifier)
              .setShowOtherDutyGroupsInCompactList(!showOtherDutyGroups),
        ),
        const SizedBox(width: glassSpacingMd),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final DateTime day;
  final AppLocalizations l10n;
  final bool compact;

  const _SheetHeader({
    required this.day,
    required this.l10n,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final String localeName = Localizations.localeOf(context).toString();
    final String weekday = DateFormat(
      'EEEE',
      localeName,
    ).format(day).toUpperCase();
    final String monthYear = DateFormat('MMMM yyyy', localeName).format(day);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isToday = _isSameDay(day, DateTime.now());
    return Padding(
      padding: EdgeInsets.fromLTRB(
        glassSpacingXl - 4 + (compact ? 0 : 40),
        glassSpacingMd,
        glassSpacingXl - 4 + (compact ? 0 : 120),
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
                if (isToday) _TodayPill(label: l10n.today),
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
          // The translucent accent is pale in Light; use a readable neutral
          // foreground rather than the opaque primary color's white label.
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
