import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class CalendarDateSelectorHeader extends ConsumerWidget {
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final Locale locale;
  final Function(DateTime) onDateSelected;
  final VoidCallback? onTodayButtonPressed;

  const CalendarDateSelectorHeader({
    super.key,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.locale,
    required this.onDateSelected,
    this.onTodayButtonPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(scheduleCoordinatorProvider).value;
    final focusedDay = state?.focusedDay ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left navigation button
          _buildNavigationButton(
            context: context,
            icon: Icons.chevron_left,
            onTap: onLeftChevronTap,
            tooltip: l10n.previousPeriod,
          ),

          const SizedBox(width: 8),

          // Date Switcher with Today button (center)
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarDateSelector(
                    currentDate: focusedDay,
                    onDateSelected: onDateSelected,
                    locale: locale,
                    selectedDay: state?.selectedDay,
                  ),
                  _buildTodayButton(context, l10n, ref),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Right navigation button
          _buildNavigationButton(
            context: context,
            icon: Icons.chevron_right,
            onTap: onRightChevronTap,
            tooltip: l10n.nextPeriod,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayButton(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Forward to the provided Today callback to centralize handling
          onTodayButtonPressed?.call();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.today,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
