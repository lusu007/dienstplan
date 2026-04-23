import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/schedule_day_filtering.dart';

/// Glass-morphism styled dialog presenting the duties for a single day.
///
/// Shown when the user taps a calendar day. The surface is built from a
/// translucent tint, two ambient colour blobs behind a heavy blur and a
/// double-border Glas-Kante, so the dialog feels like a pane of frosted glass
/// floating over the calendar.
class SchedulesDialog extends ConsumerStatefulWidget {
  final DateTime day;

  const SchedulesDialog({super.key, required this.day});

  static Future<void> show(BuildContext context, DateTime day) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            // Animated backdrop blur grows in alongside the dialog so the
            // calendar behind the modal softly fades out.
            FadeTransition(
              opacity: curved,
              child: IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SchedulesDialog(day: day);
      },
    ).then((void _) {
      if (!context.mounted) {
        return;
      }
      // Restoring focus after a route pop often selects the first TextField
      // (bottom quick title), which opens the IME and shrinks the calendar.
      // Clear focus on the next frame so that does not run.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  @override
  ConsumerState<SchedulesDialog> createState() => _SchedulesDialogState();
}

class _SchedulesDialogState extends ConsumerState<SchedulesDialog> {
  static const double _swipeVelocityThreshold = 500.0;
  static const double _swipeDistanceThreshold = 80.0;

  double _accumulatedDrag = 0.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final List<Schedule> schedulesForDay = filterSchedulesForSingleDay(
      state?.schedules,
      widget.day,
    );
    final bool hasSchedulesForDay = schedulesForDay.isNotEmpty;
    final bool isLoadingSelectedDay =
        (state?.isLoading ?? false) && !hasSchedulesForDay;

    schedulePostFrameEnsureDayIfEmpty(
      ref: ref,
      context: context,
      day: widget.day,
      hasSchedulesForDay: hasSchedulesForDay,
      isLoadingSelectedDay: isLoadingSelectedDay,
      activeConfigName: state?.activeConfigName,
    );

    final MediaQueryData media = MediaQuery.of(context);
    final double maxDialogHeight = media.size.height * 0.72;

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          media.padding.top + 32,
          20,
          media.padding.bottom + 32,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: maxDialogHeight,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: (_) {
              _accumulatedDrag = 0.0;
            },
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! > 0) {
                _accumulatedDrag += details.primaryDelta!;
              } else if (details.primaryDelta != null &&
                  details.primaryDelta! < 0) {
                _accumulatedDrag = (_accumulatedDrag + details.primaryDelta!)
                    .clamp(0.0, double.infinity);
              }
            },
            onVerticalDragEnd: (details) {
              final double velocity = details.primaryVelocity ?? 0.0;
              final bool isFlickDown = velocity > _swipeVelocityThreshold;
              final bool isDraggedDownFarEnough =
                  _accumulatedDrag > _swipeDistanceThreshold;
              if (isFlickDown || isDraggedDownFarEnough) {
                Navigator.of(context).maybePop();
              }
              _accumulatedDrag = 0.0;
            },
            child: GlassDialogSurface(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeroHeader(day: widget.day, l10n: l10n),
                    const SoftGradientDivider(),
                    Flexible(
                      child: ScrollFadeMask(
                        topFadeFraction: 0.04,
                        bottomFadeFraction: 0.08,
                        child: DutyScheduleList(
                          schedules: schedulesForDay,
                          activeConfigName: state?.activeConfigName,
                          dutyTypeOrder: state?.activeConfig?.dutyTypeOrder,
                          dutyTypes: state?.activeConfig?.dutyTypes,
                          shouldAnimate: false,
                          isLoading: isLoadingSelectedDay,
                          selectedDay: widget.day,
                          visualStyle: DutyListVisualStyle.glass,
                          topPadding: 24,
                          bottomPadding: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final DateTime day;
  final AppLocalizations l10n;

  const _HeroHeader({required this.day, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String weekday = DateFormat(
      'EEEE',
      languageCode,
    ).format(day).toUpperCase();
    final String monthYear = DateFormat('MMMM yyyy', languageCode).format(day);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isToday = _isSameDay(day, DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  fontSize: 52,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthYear,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                _TodayPill(label: l10n.today),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.38 : 0.3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.45),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
