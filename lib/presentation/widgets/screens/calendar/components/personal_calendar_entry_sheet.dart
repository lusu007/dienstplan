import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/glass_chip_tokens.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
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
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:intl/intl.dart';

const double _kTimeWheelHeight = 140;
const double _kTimeWheelItemExtent = 36;
const double _kTimeWheelDiameterRatio = 1.45;
const double _kSaveButtonHeight = 48;

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
  static const int _defaultStartMinutes = 16 * 60;
  static const int _defaultEndMinutes = 17 * 60;
  late PersonalCalendarEntry _draft;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late final FixedExtentScrollController _hourWheelController;
  late final FixedExtentScrollController _minuteWheelController;
  _TimeField _activeTimeField = _TimeField.start;
  bool _isDatePickerExpanded = false;
  bool _isTimePickerExpanded = false;

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
    if (!_draft.isAllDay) {
      _draft = _ensureTimeRange(_draft);
    }
    final int initialMinutes = _selectedMinutesForActiveField();
    _hourWheelController = FixedExtentScrollController(
      initialItem: initialMinutes ~/ 60,
    );
    _minuteWheelController = FixedExtentScrollController(
      initialItem: initialMinutes % 60,
    );
  }

  @override
  void dispose() {
    _hourWheelController.dispose();
    _minuteWheelController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _newId() {
    final Random r = Random();
    return 'pe-${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(1 << 20)}';
  }

  InputDecoration _glassFieldDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fill = Colors.white.withValues(
      alpha: isDark ? glassTintAlphaDark : glassTintAlphaLight,
    );
    final Color border = Colors.white.withValues(
      alpha: isDark ? glassBorderAlphaDark : glassBorderAlphaLight,
    );
    final OutlineInputBorder outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
      borderSide: BorderSide(color: border),
    );
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: fill,
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  PersonalCalendarEntry _ensureTimeRange(PersonalCalendarEntry entry) {
    final int start = entry.startMinutesFromMidnight ?? _defaultStartMinutes;
    final int end = entry.endMinutesFromMidnight ?? _defaultEndMinutes;
    final int safeEnd = end <= start ? start + 60 : end;
    return entry.copyWith(
      startMinutesFromMidnight: start,
      endMinutesFromMidnight: safeEnd.clamp(0, 23 * 60 + 59),
    );
  }

  int _selectedMinutesForActiveField() {
    if (_activeTimeField == _TimeField.start) {
      return _draft.startMinutesFromMidnight ?? _defaultStartMinutes;
    }
    return _draft.endMinutesFromMidnight ?? _defaultEndMinutes;
  }

  void _syncTimeWheelControllers() {
    if (!_hourWheelController.hasClients ||
        !_minuteWheelController.hasClients) {
      return;
    }
    final int minutes = _selectedMinutesForActiveField();
    final int hour = minutes ~/ 60;
    final int minute = minutes % 60;
    _hourWheelController.jumpToItem(hour);
    _minuteWheelController.jumpToItem(minute);
  }

  void _setActiveTimeField(_TimeField field) {
    if (_activeTimeField == field) {
      return;
    }
    setState(() {
      _activeTimeField = field;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncTimeWheelControllers();
    });
  }

  void _applyWheelTime({int? hour, int? minute}) {
    final int baseMinutes = _selectedMinutesForActiveField();
    final int nextHour = hour ?? (baseMinutes ~/ 60);
    final int nextMinute = minute ?? (baseMinutes % 60);
    final int nextTotal = nextHour * 60 + nextMinute;
    setState(() {
      if (_activeTimeField == _TimeField.start) {
        final int end = _draft.endMinutesFromMidnight ?? _defaultEndMinutes;
        final int adjustedEnd = end <= nextTotal ? nextTotal + 60 : end;
        _draft = _draft.copyWith(
          startMinutesFromMidnight: nextTotal,
          endMinutesFromMidnight: adjustedEnd.clamp(0, 23 * 60 + 59),
        );
      } else {
        final int start =
            _draft.startMinutesFromMidnight ?? _defaultStartMinutes;
        final int adjustedEnd = nextTotal <= start ? start + 60 : nextTotal;
        _draft = _draft.copyWith(
          endMinutesFromMidnight: adjustedEnd.clamp(0, 23 * 60 + 59),
        );
      }
    });
  }

  void _toggleDatePicker() {
    setState(() {
      final bool nextExpanded = !_isDatePickerExpanded;
      _isDatePickerExpanded = nextExpanded;
      if (nextExpanded) {
        _isTimePickerExpanded = false;
      }
    });
  }

  void _toggleTimePicker() {
    if (_draft.isAllDay) {
      return;
    }
    final bool nextExpanded = !_isTimePickerExpanded;
    setState(() {
      _isTimePickerExpanded = nextExpanded;
      if (nextExpanded) {
        _isDatePickerExpanded = false;
      }
    });
    if (!nextExpanded) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncTimeWheelControllers();
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool? confirmed = await GlassAppDialog.show<bool>(
      context: context,
      title: l10n.deletePersonalEntryConfirmationTitle,
      content: Text(l10n.deletePersonalEntryConfirmationMessage),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );
    if (!mounted || confirmed != true) {
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
    final String sheetTitle = widget.existingSchedule != null
        ? l10n.personalEntrySheetTitleEdit
        : l10n.personalEntrySheetTitleNew;
    final double keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final bool isEditing = widget.existingSchedule != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !mounted) {
          return;
        }
        final FocusScopeNode focusScope = FocusScope.of(context);
        final bool hasFocusedInput =
            focusScope.hasPrimaryFocus || focusScope.focusedChild != null;
        if (hasFocusedInput) {
          focusScope.unfocus();
          return;
        }
        Navigator.of(context).pop();
      },
      child: GlassBottomSheet(
        shrinkToContent: true,
        children: <Widget>[
          _PersonalEntrySheetHeader(
            title: sheetTitle,
            deleteTooltip: l10n.personalEntryDeleteTooltip,
            onDelete: isEditing ? _delete : null,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              glassSpacingLg,
              glassSpacingMd,
              glassSpacingLg,
              glassSpacingLg + keyboardBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _SectionEyebrow(
                  text: l10n.personalEntryTitleLabel,
                  enabled: true,
                ),
                const SizedBox(height: glassSpacingXs),
                TextField(
                  controller: _titleController,
                  decoration: _glassFieldDecoration(
                    context,
                    hintText: l10n.personalEntryTitleLabel,
                  ),
                ),
                const SizedBox(height: glassSpacingLg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GlassFilterChip(
                        label: l10n.personalEntryKindAppointment,
                        isSelected:
                            _draft.kind ==
                            PersonalCalendarEntryKind.appointment,
                        expandWidth: true,
                        onTap: () {
                          setState(() {
                            _draft = _draft.copyWith(
                              kind: PersonalCalendarEntryKind.appointment,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: glassSpacingSm),
                    Expanded(
                      child: GlassFilterChip(
                        label: l10n.personalEntryKindDuty,
                        isSelected:
                            _draft.kind ==
                            PersonalCalendarEntryKind.personalDuty,
                        expandWidth: true,
                        onTap: () {
                          setState(() {
                            _draft = _draft.copyWith(
                              kind: PersonalCalendarEntryKind.personalDuty,
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: glassSpacingMd),
                SwitchListTile(
                  tileColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.personalEntryAllDayLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
                const SizedBox(height: glassSpacingXs),
                _InlineDateTimeSection(
                  draft: _draft,
                  activeTimeField: _activeTimeField,
                  isDatePickerExpanded: _isDatePickerExpanded,
                  isTimePickerExpanded: _isTimePickerExpanded,
                  hourWheelController: _hourWheelController,
                  minuteWheelController: _minuteWheelController,
                  dateLabel: l10n.personalEntryDateLabel,
                  timeLabel: l10n.personalEntryTimeLabel,
                  onToggleDatePicker: _toggleDatePicker,
                  onToggleTimePicker: _toggleTimePicker,
                  onDateChanged: (DateTime value) {
                    setState(() {
                      _draft = _draft.copyWith(
                        date: DateTime.utc(value.year, value.month, value.day),
                      );
                    });
                  },
                  onSelectStartTime: () =>
                      _setActiveTimeField(_TimeField.start),
                  onSelectEndTime: () => _setActiveTimeField(_TimeField.end),
                  onHourChanged: (int hour) => _applyWheelTime(hour: hour),
                  onMinuteChanged: (int minute) =>
                      _applyWheelTime(minute: minute),
                ),
                const SizedBox(height: glassSpacingMd),
                _SectionEyebrow(
                  text: l10n.personalEntryNotesLabel,
                  enabled: true,
                ),
                const SizedBox(height: glassSpacingXs),
                TextField(
                  controller: _notesController,
                  decoration: _glassFieldDecoration(
                    context,
                    hintText: l10n.personalEntryNotesLabel,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: glassSpacingLg),
                GlassButtonSurface(
                  onTap: _save,
                  enabled: true,
                  borderRadius: glassSurfaceRadiusSm,
                  height: _kSaveButtonHeight,
                  fullWidth: true,
                  child: Text(
                    l10n.save,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TimeField { start, end }

class _PersonalEntrySheetHeader extends StatelessWidget {
  final String title;
  final String deleteTooltip;
  final VoidCallback? onDelete;

  const _PersonalEntrySheetHeader({
    required this.title,
    required this.deleteTooltip,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        glassSpacingLg,
        glassSpacingLg,
        glassSpacingLg,
        glassSpacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (onDelete != null) ...<Widget>[
            const SizedBox(width: glassSpacingSm),
            _GlassIconActionChip(
              icon: Icons.delete_outline_rounded,
              tooltip: deleteTooltip,
              iconColor: colorScheme.error,
              onTap: onDelete!,
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassIconActionChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassIconActionChip({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = Colors.white.withValues(
      alpha: isDark
          ? kGlassChipUnselectedTintAlphaDark
          : kGlassChipUnselectedTintAlphaLight,
    );
    final Color borderColor = Colors.white.withValues(
      alpha: isDark
          ? kGlassChipUnselectedBorderAlphaDark
          : kGlassChipUnselectedBorderAlphaLight,
    );
    final Widget chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kGlassIconChipRadius),
        child: Container(
          width: kGlassIconChipSize,
          height: kGlassIconChipSize,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(kGlassIconChipRadius),
            border: Border.all(
              color: borderColor,
              width: kGlassChipBorderWidth,
            ),
          ),
          child: Icon(icon, size: kGlassIconChipIconSize, color: iconColor),
        ),
      ),
    );
    return Tooltip(message: tooltip, child: chip);
  }
}

class _InlineDateTimeSection extends StatelessWidget {
  final PersonalCalendarEntry draft;
  final _TimeField activeTimeField;
  final bool isDatePickerExpanded;
  final bool isTimePickerExpanded;
  final FixedExtentScrollController hourWheelController;
  final FixedExtentScrollController minuteWheelController;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback onToggleDatePicker;
  final VoidCallback onToggleTimePicker;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const _InlineDateTimeSection({
    required this.draft,
    required this.activeTimeField,
    required this.isDatePickerExpanded,
    required this.isTimePickerExpanded,
    required this.hourWheelController,
    required this.minuteWheelController,
    required this.dateLabel,
    required this.timeLabel,
    required this.onToggleDatePicker,
    required this.onToggleTimePicker,
    required this.onDateChanged,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  TimeOfDay _toTime(int? minutes, int fallbackMinutes) {
    final int value = minutes ?? fallbackMinutes;
    return TimeOfDay(hour: value ~/ 60, minute: value % 60);
  }

  String _formatDate(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(DateTime(value.year, value.month, value.day));
  }

  String _formatTime(BuildContext context, TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(value);
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay startTime = _toTime(
      draft.startMinutesFromMidnight,
      16 * 60,
    );
    final TimeOfDay endTime = _toTime(draft.endMinutesFromMidnight, 17 * 60);
    final DateTime firstDate = DateTime(
      CalendarConfig.firstDay.year,
      CalendarConfig.firstDay.month,
      CalendarConfig.firstDay.day,
    );
    final DateTime lastDate = DateTime(
      CalendarConfig.lastDay.year,
      CalendarConfig.lastDay.month,
      CalendarConfig.lastDay.day,
    );
    final bool isTimeEnabled = !draft.isAllDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionEyebrow(text: dateLabel, enabled: true),
        const SizedBox(height: glassSpacingXs),
        _InlineExpandTile(
          icon: Icons.calendar_today_rounded,
          label: _formatDate(context, draft.date),
          isExpanded: isDatePickerExpanded,
          onTap: onToggleDatePicker,
        ),
        const SizedBox(height: glassSpacingMd),
        _SectionEyebrow(text: timeLabel, enabled: isTimeEnabled),
        const SizedBox(height: glassSpacingXs),
        _InlineExpandTile(
          icon: Icons.schedule_rounded,
          label:
              '${_formatTime(context, startTime)} - ${_formatTime(context, endTime)}',
          isExpanded: isTimePickerExpanded && isTimeEnabled,
          enabled: isTimeEnabled,
          onTap: onToggleTimePicker,
        ),
        if (isDatePickerExpanded) ...<Widget>[
          const SizedBox(height: glassSpacingSm),
          CalendarDatePicker(
            initialDate: DateTime(
              draft.date.year,
              draft.date.month,
              draft.date.day,
            ),
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: onDateChanged,
          ),
        ] else if (isTimePickerExpanded && isTimeEnabled) ...<Widget>[
          const SizedBox(height: glassSpacingSm),
          Row(
            children: <Widget>[
              Expanded(
                child: _InlineDateTimeTile(
                  label: _formatTime(context, startTime),
                  isSelected: activeTimeField == _TimeField.start,
                  onTap: onSelectStartTime,
                ),
              ),
              const SizedBox(width: glassSpacingSm),
              Expanded(
                child: _InlineDateTimeTile(
                  label: _formatTime(context, endTime),
                  isSelected: activeTimeField == _TimeField.end,
                  onTap: onSelectEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: glassSpacingSm),
          _InlineTimeWheel(
            hourController: hourWheelController,
            minuteController: minuteWheelController,
            onHourChanged: onHourChanged,
            onMinuteChanged: onMinuteChanged,
          ),
        ],
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;
  final bool enabled;

  const _SectionEyebrow({required this.text, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(
          alpha: enabled ? 1.0 : 0.5,
        ),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InlineExpandTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool enabled;
  final VoidCallback onTap;

  const _InlineExpandTile({
    required this.icon,
    required this.label,
    required this.isExpanded,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foreground = colorScheme.onSurface.withValues(
      alpha: enabled ? 1.0 : 0.5,
    );
    final Color trailing = colorScheme.onSurfaceVariant.withValues(
      alpha: enabled ? 1.0 : 0.5,
    );
    return GlassCard(
      onTap: onTap,
      enabled: enabled,
      padding: const EdgeInsets.symmetric(
        horizontal: glassSpacingMd,
        vertical: glassSpacingMd,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: trailing),
          const SizedBox(width: glassSpacingMd),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            enabled && isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: trailing,
          ),
        ],
      ),
    );
  }
}

class _InlineDateTimeTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InlineDateTimeTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GlassCard(
      onTap: onTap,
      isActive: isSelected,
      padding: const EdgeInsets.symmetric(
        horizontal: glassSpacingMd,
        vertical: glassSpacingMd,
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InlineTimeWheel extends StatelessWidget {
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const _InlineTimeWheel({
    required this.hourController,
    required this.minuteController,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: _kTimeWheelHeight,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _WheelColumn(
              controller: hourController,
              itemCount: 24,
              onSelectedItemChanged: onHourChanged,
              itemBuilder: (int index) => index.toString().padLeft(2, '0'),
            ),
          ),
          Text(
            ':',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: _WheelColumn(
              controller: minuteController,
              itemCount: 60,
              onSelectedItemChanged: onMinuteChanged,
              itemBuilder: (int index) => index.toString().padLeft(2, '0'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final ValueChanged<int> onSelectedItemChanged;
  final String Function(int) itemBuilder;

  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.onSelectedItemChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _kTimeWheelItemExtent,
      diameterRatio: _kTimeWheelDiameterRatio,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (BuildContext context, int index) {
          if (index < 0 || index >= itemCount) {
            return null;
          }
          return Center(
            child: Text(
              itemBuilder(index),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
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
    barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext ctx) => PersonalCalendarEntrySheet(
      day: day,
      existingSchedule: existingSchedule,
      dutyGroupNameForNew: dutyGroup,
      initialTitle: initialTitle,
    ),
  );
}
