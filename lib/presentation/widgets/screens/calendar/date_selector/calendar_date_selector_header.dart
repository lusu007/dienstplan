import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class CalendarDateSelectorHeader extends StatefulWidget {
  final ScheduleController scheduleController;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final Locale locale;
  final Function(DateTime) onDateSelected;
  final VoidCallback? onTodayButtonPressed;

  const CalendarDateSelectorHeader({
    super.key,
    required this.scheduleController,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.locale,
    required this.onDateSelected,
    this.onTodayButtonPressed,
  });

  @override
  State<CalendarDateSelectorHeader> createState() =>
      _CalendarDateSelectorHeaderState();
}

class _CalendarDateSelectorHeaderState
    extends State<CalendarDateSelectorHeader> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes
    widget.scheduleController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // Remove listener
    widget.scheduleController.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Rebuild when controller changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final focusedDay = widget.scheduleController.focusedDay ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left navigation button
          _buildNavigationButton(
            context: context,
            icon: Icons.chevron_left,
            onTap: widget.onLeftChevronTap,
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
                    onDateSelected: widget.onDateSelected,
                    locale: widget.locale,
                    selectedDay: widget.scheduleController.selectedDay,
                  ),
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
            onTap: widget.onRightChevronTap,
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
        onTap: () async {
          final now = DateTime.now();

          // Set the selected and focused day
          widget.scheduleController.setSelectedDay(now);
          widget.scheduleController.setFocusedDay(now);

          // Call the callback if provided
          widget.onTodayButtonPressed?.call();

          // Force multiple rebuilds to ensure proper synchronization
          // This ensures the PageView is rebuilt around the new "today" day
          for (int i = 0; i < 3; i++) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
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
