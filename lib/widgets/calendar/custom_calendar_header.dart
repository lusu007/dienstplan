import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/widgets/calendar/date_switcher.dart';
import 'package:dienstplan/l10n/app_localizations.dart';

class CustomCalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final Locale locale;
  final Function(DateTime) onDateSelected;

  const CustomCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.locale,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  DateSwitcher(
                    currentDate: focusedDay,
                    onDateSelected: onDateSelected,
                    locale: locale,
                  ),
                  const SizedBox(width: 12),
                  _buildTodayButton(context, l10n),
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

  Widget _buildTodayButton(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final now = DateTime.now();
          final scheduleProvider = context.read<ScheduleProvider>();
          scheduleProvider.setSelectedDay(now);
          scheduleProvider.setFocusedDay(now);
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
