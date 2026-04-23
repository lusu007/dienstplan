import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/personal_calendar_constants.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/services/personal_entry_schedule_mapper.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:intl/intl.dart';

/// Bottom sheet to create or edit a personal calendar entry (appointment / own duty).
class PersonalCalendarEntrySheet extends ConsumerStatefulWidget {
  final DateTime day;
  final Schedule? existingSchedule;
  final String dutyGroupNameForNew;
  final String? initialTitle;

  const PersonalCalendarEntrySheet({
    super.key,
    required this.day,
    required this.existingSchedule,
    required this.dutyGroupNameForNew,
    this.initialTitle,
  });

  @override
  ConsumerState<PersonalCalendarEntrySheet> createState() =>
      _PersonalCalendarEntrySheetState();
}

class _PersonalCalendarEntrySheetState
    extends ConsumerState<PersonalCalendarEntrySheet> {
  static const FailurePresenter _failurePresenter = FailurePresenter();
  late PersonalCalendarEntry _draft;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final DateTime d = DateTime.utc(
      widget.day.year,
      widget.day.month,
      widget.day.day,
    );
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (widget.existingSchedule != null) {
      _draft = PersonalEntryScheduleMapper.entryFromSchedule(
        widget.existingSchedule!,
      );
    } else {
      final String? quickTitle = widget.initialTitle?.trim();
      final String title = (quickTitle != null && quickTitle.isNotEmpty)
          ? quickTitle
          : '';
      _draft = PersonalCalendarEntry(
        id: _newId(),
        kind: PersonalCalendarEntryKind.appointment,
        title: title,
        notes: null,
        date: d,
        isAllDay: true,
        startMinutesFromMidnight: null,
        endMinutesFromMidnight: null,
        dutyGroupName: widget.dutyGroupNameForNew,
        createdAtMs: nowMs,
        updatedAtMs: nowMs,
      );
    }
    _titleController.text = _draft.title;
    _notesController.text = _draft.notes ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _newId() {
    final Random r = Random();
    return 'pe-${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(1 << 20)}';
  }

  TimeOfDay? _minutesToTimeOfDay(int? minutes) {
    if (minutes == null) {
      return null;
    }
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  int _timeOfDayToMinutes(TimeOfDay t) {
    return t.hour * 60 + t.minute;
  }

  String _formatEntryDate(BuildContext context) {
    final DateTime d = _draft.date;
    final DateTime local = DateTime(d.year, d.month, d.day);
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(local);
  }

  InputDecoration _glassFieldDecoration(
    BuildContext context, {
    required String labelText,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fill = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.08 : 0.07,
    );
    final Color border = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.22 : 0.18,
    );
    final OutlineInputBorder outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border),
    );
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: fill,
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime initial = DateTime(
      _draft.date.year,
      _draft.date.month,
      _draft.date.day,
    );
    final DateTime first = DateTime(
      CalendarConfig.firstDay.year,
      CalendarConfig.firstDay.month,
      CalendarConfig.firstDay.day,
    );
    final DateTime last = DateTime(
      CalendarConfig.lastDay.year,
      CalendarConfig.lastDay.month,
      CalendarConfig.lastDay.day,
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _draft = _draft.copyWith(
        date: DateTime.utc(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay initial =
        _minutesToTimeOfDay(
          isStart
              ? _draft.startMinutesFromMidnight
              : _draft.endMinutesFromMidnight,
        ) ??
        TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      final int m = _timeOfDayToMinutes(picked);
      if (isStart) {
        _draft = _draft.copyWith(startMinutesFromMidnight: m);
      } else {
        _draft = _draft.copyWith(endMinutesFromMidnight: m);
      }
    });
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final PersonalCalendarEntry toSave = _draft.copyWith(
      title: _titleController.text,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      updatedAtMs: nowMs,
    );
    final saveUseCase = await ref.read(
      savePersonalCalendarEntryUseCaseProvider.future,
    );
    final result = await saveUseCase.execute(toSave);
    if (!mounted) {
      return;
    }
    if (result.isFailure) {
      final String message = _failurePresenter.present(result.failure, l10n);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await ref
        .read(scheduleDataProvider.notifier)
        .refreshPersonalCalendarEntries();
    await ref
        .read(scheduleCoordinatorProvider.notifier)
        .syncScheduleDataFromProvider();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.personalEntrySaved)));
    }
  }

  Future<void> _delete() async {
    final String id = _draft.id;
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (widget.existingSchedule == null) {
      return;
    }
    final deleteUseCase = await ref.read(
      deletePersonalCalendarEntryUseCaseProvider.future,
    );
    final result = await deleteUseCase.execute(id);
    if (!mounted) {
      return;
    }
    if (result.isFailure) {
      final String message = _failurePresenter.present(result.failure, l10n);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await ref
        .read(scheduleDataProvider.notifier)
        .refreshPersonalCalendarEntries();
    await ref
        .read(scheduleCoordinatorProvider.notifier)
        .syncScheduleDataFromProvider();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.personalEntryDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TimeOfDay? startT = _minutesToTimeOfDay(
      _draft.startMinutesFromMidnight,
    );
    final TimeOfDay? endT = _minutesToTimeOfDay(_draft.endMinutesFromMidnight);
    final String sheetTitle = widget.existingSchedule != null
        ? l10n.personalEntrySheetTitleEdit
        : l10n.personalEntrySheetTitleNew;
    final double keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return GlassBottomSheet(
      title: sheetTitle,
      shrinkToContent: true,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + keyboardBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SegmentedButton<PersonalCalendarEntryKind>(
                segments: <ButtonSegment<PersonalCalendarEntryKind>>[
                  ButtonSegment<PersonalCalendarEntryKind>(
                    value: PersonalCalendarEntryKind.appointment,
                    label: Text(l10n.personalEntryKindAppointment),
                  ),
                  ButtonSegment<PersonalCalendarEntryKind>(
                    value: PersonalCalendarEntryKind.personalDuty,
                    label: Text(l10n.personalEntryKindDuty),
                  ),
                ],
                selected: <PersonalCalendarEntryKind>{_draft.kind},
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.primary;
                    }
                    return colorScheme.onSurface.withValues(alpha: 0.1);
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return colorScheme.onPrimary;
                    }
                    return colorScheme.onSurface;
                  }),
                ),
                onSelectionChanged: (Set<PersonalCalendarEntryKind> next) {
                  setState(() {
                    _draft = _draft.copyWith(kind: next.first);
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.personalEntryDateLabel,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  _formatEntryDate(context),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.calendar_today_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: _glassFieldDecoration(
                  context,
                  labelText: l10n.personalEntryTitleLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: _glassFieldDecoration(
                  context,
                  labelText: l10n.personalEntryNotesLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                tileColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.personalEntryAllDayLabel,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                value: _draft.isAllDay,
                onChanged: (bool v) {
                  setState(() {
                    _draft = _draft.copyWith(
                      isAllDay: v,
                      startMinutesFromMidnight: v
                          ? null
                          : _draft.startMinutesFromMidnight,
                      endMinutesFromMidnight: v
                          ? null
                          : _draft.endMinutesFromMidnight,
                    );
                  });
                },
              ),
              if (!_draft.isAllDay) ...<Widget>[
                ListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.personalEntryStartTime,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    startT?.format(context) ?? '—',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Icon(
                    Icons.schedule,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => _pickTime(isStart: true),
                ),
                ListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.personalEntryEndTime,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    endT?.format(context) ?? '—',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Icon(
                    Icons.schedule,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => _pickTime(isStart: false),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  if (widget.existingSchedule != null)
                    TextButton(
                      onPressed: _delete,
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: Text(l10n.delete),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: Text(l10n.save)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showPersonalCalendarEntrySheet({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime day,
  Schedule? existingSchedule,
  String? initialTitle,
}) {
  final String dutyGroup =
      ref.read(settingsProvider).value?.myDutyGroup?.trim().isNotEmpty == true
      ? ref.read(settingsProvider).value!.myDutyGroup!.trim()
      : kPersonalFallbackDutyGroupName;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext ctx) => PersonalCalendarEntrySheet(
      day: day,
      existingSchedule: existingSchedule,
      dutyGroupNameForNew: dutyGroup,
      initialTitle: initialTitle,
    ),
  );
}
