import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/calendar_export_options.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarExportBottomsheet extends ConsumerStatefulWidget {
  const CalendarExportBottomsheet({super.key});

  static Future<void> show(
    BuildContext context, {
    double heightPercentage = 0.72,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CalendarExportBottomsheet(),
    );
  }

  @override
  ConsumerState<CalendarExportBottomsheet> createState() =>
      _CalendarExportBottomsheetState();
}

class _CalendarExportBottomsheetState
    extends ConsumerState<CalendarExportBottomsheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _includePartnerSchedule = false;
  bool _includeHolidays = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsState = ref.watch(settingsProvider).value;
    final holidaysState = ref.watch(schoolHolidaysProvider).value;

    final hasPartnerSchedule =
        (settingsState?.partnerConfigName?.isNotEmpty ?? false) &&
        (settingsState?.partnerDutyGroup?.isNotEmpty ?? false);
    final hasHolidayConfiguration =
        holidaysState?.selectedStateCode?.isNotEmpty ?? false;
    final effectiveIncludePartner =
        hasPartnerSchedule && _includePartnerSchedule;
    final effectiveIncludeHolidays =
        hasHolidayConfiguration && _includeHolidays;

    return GenericBottomsheet(
      title: l10n.exportCalendar,
      heightPercentage: 0.76,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.exportCalendarDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _DateCard(
                title: l10n.exportCalendarStartDate,
                value: _formatDate(context, _startDate),
                icon: Icons.date_range_outlined,
                onTap: () => _pickDate(
                  initialDate: _startDate,
                  firstDate: DateTime(2020, 1, 1),
                  lastDate: DateTime(2100, 12, 31),
                  onSelected: (value) => setState(() => _startDate = value),
                ),
              ),
              const SizedBox(height: 12),
              _DateCard(
                title: l10n.exportCalendarEndDate,
                value: _formatDate(context, _endDate),
                icon: Icons.event_outlined,
                onTap: () => _pickDate(
                  initialDate: _endDate,
                  firstDate: DateTime(2020, 1, 1),
                  lastDate: DateTime(2100, 12, 31),
                  onSelected: (value) => setState(() => _endDate = value),
                ),
              ),
              const SizedBox(height: 20),
              _ToggleCard(
                title: l10n.exportCalendarIncludePartner,
                subtitle: hasPartnerSchedule
                    ? l10n.exportCalendarIncludePartnerDescription
                    : l10n.exportCalendarPartnerUnavailable,
                value: effectiveIncludePartner,
                enabled: hasPartnerSchedule,
                onChanged: (value) {
                  if (!hasPartnerSchedule) {
                    return;
                  }
                  setState(() => _includePartnerSchedule = value);
                },
              ),
              const SizedBox(height: 12),
              _ToggleCard(
                title: l10n.exportCalendarIncludeHolidays,
                subtitle: hasHolidayConfiguration
                    ? l10n.exportCalendarIncludeHolidaysDescription
                    : l10n.exportCalendarHolidayUnavailable,
                value: effectiveIncludeHolidays,
                enabled: hasHolidayConfiguration,
                onChanged: (value) {
                  if (!hasHolidayConfiguration) {
                    return;
                  }
                  setState(() => _includeHolidays = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isExporting ? null : _exportCalendar,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_outlined),
                  label: Text(l10n.exportCalendarButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      onSelected(DateTime(selected.year, selected.month, selected.day));
    }
  }

  String _formatDate(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }

  Future<void> _exportCalendar() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final settingsState = ref.read(settingsProvider).value;
    final holidaysState = ref.read(schoolHolidaysProvider).value;
    final hasPartnerSchedule =
        (settingsState?.partnerConfigName?.isNotEmpty ?? false) &&
        (settingsState?.partnerDutyGroup?.isNotEmpty ?? false);
    final hasHolidayConfiguration =
        holidaysState?.selectedStateCode?.isNotEmpty ?? false;
    final includePartnerSchedule =
        hasPartnerSchedule && _includePartnerSchedule;
    final includeHolidays = hasHolidayConfiguration && _includeHolidays;

    if (_startDate.isAfter(_endDate)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.exportCalendarInvalidRange),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final generateExportUseCase = await ref.read(
        generateCalendarExportUseCaseProvider.future,
      );
      final exportResult = await generateExportUseCase.execute(
        CalendarExportOptions(
          startDate: _startDate,
          endDate: _endDate,
          includePartnerSchedule: includePartnerSchedule,
          includeHolidays: includeHolidays,
        ),
      );

      if (exportResult.isFailure) {
        if (!mounted) {
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(_resolveFailureMessage(exportResult.failure, l10n)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final calendarExportService = ref.read(calendarExportServiceProvider);
      final shareResult = await calendarExportService.shareCalendarExport(
        payload: exportResult.value,
        l10n: l10n,
      );

      if (shareResult.isFailure) {
        if (!mounted) {
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.exportCalendarError),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.exportCalendarSuccess(shareResult.value.entryCount),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export failed (startDate=${_startDate.toIso8601String()}, endDate=${_endDate.toIso8601String()}, includePartner=$includePartnerSchedule, includeHolidays=$includeHolidays, reason=unexpected_ui_error)',
        error,
        stackTrace,
      );
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.exportCalendarError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _resolveFailureMessage(Failure failure, AppLocalizations l10n) {
    switch (failure.userMessageKey) {
      case 'calendarExportInvalidRange':
        return l10n.exportCalendarInvalidRange;
      case 'calendarExportNoActiveSchedule':
        return l10n.exportCalendarNoActiveSchedule;
      case 'calendarExportPartnerUnavailable':
        return l10n.exportCalendarPartnerUnavailable;
      case 'calendarExportHolidayUnavailable':
        return l10n.exportCalendarHolidayUnavailable;
      case 'calendarExportEmpty':
        return l10n.exportCalendarEmpty;
      default:
        return l10n.exportCalendarError;
    }
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? Theme.of(context).cardColor
            : Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        title: Text(title),
        subtitle: Text(subtitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
