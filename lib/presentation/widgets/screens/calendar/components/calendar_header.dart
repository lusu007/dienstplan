import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_month_title.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';

/// Custom header used in place of the default [AppBar].
///
/// Stacks two rows vertically:
/// 1. App title on the left; add personal entry and Settings glass buttons on the right.
/// 2. The tappable month/year chip, centered, directly below row 1.
class CalendarHeader extends ConsumerWidget {
  static const double kTitleRowHeight = 48.0;

  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color foreground = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kTitleRowHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppInfo.appName,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 0.2,
                    height: 1.0,
                  ),
                ),
                const Spacer(),
                _GlassPersonalEntryButton(
                  tooltip: l10n.addPersonalEntryTooltip,
                  onPressed: () {
                    final DateTime day =
                        ref.read(scheduleCoordinatorProvider).value?.selectedDay ??
                        DateTime.now();
                    showPersonalCalendarEntrySheet(
                      context: context,
                      ref: ref,
                      day: day,
                      existingSchedule: null,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _GlassSettingsButton(
                  tooltip: l10n.settings,
                  onPressed: () => context.router.push(const SettingsRoute()),
                ),
              ],
            ),
          ),
        ),
        const Center(child: CalendarMonthTitle()),
      ],
    );
  }
}

class _GlassPersonalEntryButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassPersonalEntryButton({
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
                width: 1,
              ),
            ),
            child: Icon(Icons.event_note_rounded, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}

class _GlassSettingsButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassSettingsButton({required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
                width: 1,
              ),
            ),
            child: Icon(Icons.settings_rounded, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}
