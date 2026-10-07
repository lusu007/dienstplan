import 'package:dienstplan/presentation/widgets/common/confirm_discard_changes.dart';
import 'package:dienstplan/presentation/widgets/common/app_snack_bar.dart';
import 'package:dienstplan/presentation/widgets/common/app_feedback_style.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/services/personal_entry_schedule_mapper.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_form_expand_tile.dart';
import 'package:intl/intl.dart';

const double _kTimeWheelItemExtent = 36;
const double _kTimeWheelHeight = _kTimeWheelItemExtent * 3;
const double _kTimeWheelDiameterRatio = 1000;
const double _kTimeWheelPerspective = 0.0001;
const double _kSaveButtonHeight = 48;
const int _kMinuteStep = 5;
const int _kMinuteOptionCount = 60 ~/ _kMinuteStep;
const int _kMaxSelectableMinutes = 23 * 60 + (60 - _kMinuteStep);
const int _kDefaultStartMinutes = 16 * 60;
const int _kDefaultEndMinutes = 17 * 60;

enum PersonalEntrySheetResult { saved, deleted, discarded }

/// Bottom sheet to create or edit a personal duty.
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
  late PersonalCalendarEntry _initialDraft;
  bool _busy = false;
  bool _confirmingClose = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey _titleFieldKey = GlobalKey();
  final GlobalKey _feedbackKey = GlobalKey();
  String? _titleError;
  String? _operationError;
  late final FixedExtentScrollController _hourWheelController;
  late final FixedExtentScrollController _minuteWheelController;
  _TimeField _activeTimeField = _TimeField.start;
  bool _isDatePickerExpanded = false;
  bool _editingEndDate = false;
  bool _manualEndDate = false;
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
        kind: PersonalCalendarEntryKind.personalDuty,
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
    _manualEndDate = widget.existingSchedule != null && _draft.endDate != null;
    _titleController.text = _draft.title;
    _notesController.text = _draft.notes ?? '';
    if (!_draft.isAllDay) {
      _draft = _ensureTimeRange(_draft);
    }
    _initialDraft = _draft;
    final int initialMinutes = _selectedMinutesForActiveField();
    _hourWheelController = FixedExtentScrollController(
      initialItem: initialMinutes ~/ 60,
    );
    _minuteWheelController = FixedExtentScrollController(
      initialItem: _minuteToWheelIndex(initialMinutes % 60),
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
    String? error,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fill = (isDark ? Colors.white : colorScheme.onSurface)
        .withValues(
          alpha: isDark ? glassTintAlphaDark : glassModalFillAlphaLight,
        );
    final Color border = (isDark ? Colors.white : colorScheme.onSurface)
        .withValues(
          alpha: isDark
              ? glassBorderAlphaDark
              : glassModalFieldBorderAlphaLight,
        );
    final OutlineInputBorder outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
      borderSide: BorderSide(color: border),
    );
    return InputDecoration(
      hintText: hintText,
      error: error == null
          ? null
          : Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: AppFeedbackStyle.text(colorScheme)
                    .copyWith(color: colorScheme.error),
              ),
            ),
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
    final int start = _normalizeMinutesToStep(
      entry.startMinutesFromMidnight ?? _kDefaultStartMinutes,
    );
    final int end = _normalizeMinutesToStep(
      entry.endMinutesFromMidnight ?? _kDefaultEndMinutes,
    );

    return entry.copyWith(
      startMinutesFromMidnight: start,
      endMinutesFromMidnight: end,
      endDate: entry.endDate ?? entry.date,
    );
  }

  int _selectedMinutesForActiveField() {
    if (_activeTimeField == _TimeField.start) {
      return _draft.startMinutesFromMidnight ?? _kDefaultStartMinutes;
    }
    return _draft.endMinutesFromMidnight ?? _kDefaultEndMinutes;
  }

  int _normalizeMinutesToStep(int minutesFromMidnight) {
    final int clampedMinutes = minutesFromMidnight.clamp(
      0,
      _kMaxSelectableMinutes,
    );
    final int roundedMinutes =
        ((clampedMinutes / _kMinuteStep).round() * _kMinuteStep);
    return roundedMinutes.clamp(0, _kMaxSelectableMinutes);
  }

  int _minuteToWheelIndex(int minute) {
    return _normalizeMinutesToStep(minute) ~/ _kMinuteStep;
  }

  int _wheelIndexToMinute(int index) {
    final int safeIndex = index.clamp(0, _kMinuteOptionCount - 1);
    return safeIndex * _kMinuteStep;
  }

  void _syncTimeWheelControllers() {
    if (!_hourWheelController.hasClients ||
        !_minuteWheelController.hasClients) {
      return;
    }
    final int minutes = _selectedMinutesForActiveField();
    final int hour = minutes ~/ 60;
    final int minute = _minuteToWheelIndex(minutes % 60);
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

  bool _applyWheelTime({int? hour, int? minute}) {
    final int baseMinutes = _selectedMinutesForActiveField();
    final int nextHour = hour ?? (baseMinutes ~/ 60);
    final int nextMinute = minute ?? _normalizeMinutesToStep(baseMinutes % 60);
    final int nextTotal = _normalizeMinutesToStep(nextHour * 60 + nextMinute);
    setState(() {
      if (_activeTimeField == _TimeField.start) {
        _draft = _draft.copyWith(startMinutesFromMidnight: nextTotal);
      } else {
        _draft = _draft.copyWith(endMinutesFromMidnight: nextTotal);
      }
      _updateAutomaticEndDate();
    });
    return true;
  }

  void _updateAutomaticEndDate() {
    if (_manualEndDate || _draft.isAllDay) return;
    final start = _draft.startMinutesFromMidnight ?? _kDefaultStartMinutes;
    final end = _draft.endMinutesFromMidnight ?? _kDefaultEndMinutes;
    _draft = _draft.copyWith(
      endDate: DateTime.utc(
        _draft.date.year,
        _draft.date.month,
        _draft.date.day + (end < start ? 1 : 0),
      ),
    );
  }

  void _triggerSelectionHapticFeedback() {
    HapticFeedback.selectionClick();
  }

  void _toggleDatePicker({bool end = false}) {
    setState(() {
      final bool nextExpanded =
          !_isDatePickerExpanded || _editingEndDate != end;
      _editingEndDate = end;
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

  bool get _isDirty =>
      _draft != _initialDraft ||
      _titleController.text != _initialDraft.title ||
      _notesController.text != (_initialDraft.notes ?? '');

  Future<void> _requestClose() async {
    if (_busy || _confirmingClose) return;
    _confirmingClose = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final discard = !_isDirty || await confirmDiscardChanges(context);
    _confirmingClose = false;
    if (mounted && discard) {
      Navigator.of(context).pop(PersonalEntrySheetResult.discarded);
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      setState(() {
        _titleError = null;
        _operationError = null;
      });
      final AppLocalizations l10n = AppLocalizations.of(context);
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      final PersonalCalendarEntry normalizedDraft = _draft.isAllDay
          ? _draft
          : _ensureTimeRange(_draft);
      final PersonalCalendarEntry toSave = normalizedDraft.copyWith(
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
        _showFailure(result.failure);
        return;
      }
      await ref
          .read(scheduleDataProvider.notifier)
          .refreshPersonalCalendarEntries();
      await ref
          .read(scheduleCoordinatorProvider.notifier)
          .syncScheduleDataFromProvider();
      if (mounted) {
        Navigator.of(context).pop(PersonalEntrySheetResult.saved);
        ScaffoldMessenger.of(context)
            .showSnackBar(AppSnackBar(content: Text(l10n.personalEntrySaved)));
      }
    } catch (error) {
      if (mounted) {
        _showFailure(
          UnknownFailure(technicalMessage: error.toString(), cause: error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    final String id = _draft.id;
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (widget.existingSchedule == null) {
      return;
    }
    final bool? confirmed = await GlassAppDialog.show<bool>(
      context: context,
      title: l10n.deletePersonalEntryConfirmationTitle,
      content: Text(l10n.deletePersonalEntryConfirmationMessage),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: AppGlassButton(
            role: AppGlassButtonRole.destructive,

            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.personalEntryDelete),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: AppGlassButton(
            role: AppGlassButtonRole.quiet,

            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );
    if (!mounted || confirmed != true) {
      return;
    }
    setState(() => _busy = true);
    try {
      setState(() => _operationError = null);
      final deleteUseCase = await ref.read(
        deletePersonalCalendarEntryUseCaseProvider.future,
      );
      final result = await deleteUseCase.execute(id);
      if (!mounted) {
        return;
      }
      if (result.isFailure) {
        _showFailure(result.failure);
        return;
      }
      await ref
          .read(scheduleDataProvider.notifier)
          .refreshPersonalCalendarEntries();
      await ref
          .read(scheduleCoordinatorProvider.notifier)
          .syncScheduleDataFromProvider();
      if (mounted) {
        Navigator.of(context).pop(PersonalEntrySheetResult.deleted);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackBar(content: Text(l10n.personalEntryDeleted)));
      }
    } catch (error) {
      if (mounted) {
        _showFailure(
          UnknownFailure(technicalMessage: error.toString(), cause: error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showFailure(Failure failure) {
    final message = _failurePresenter.present(
      failure,
      AppLocalizations.of(context),
    );
    final titleMissing =
        failure.userMessageKey == 'personalEntryValidationTitle';
    setState(() {
      _titleError = titleMissing ? message : null;
      _operationError = titleMissing ? null : message;
    });
    // Save can be below the visible title field; reveal the actionable error
    // after the added message has participated in layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target =
          (titleMissing ? _titleFieldKey : _feedbackKey).currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: titleMissing ? .1 : 1,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
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
        _requestClose();
      },
      child: AbsorbPointer(
        absorbing: _busy,
        child: GlassBottomSheet(
          onHandleClose: _requestClose,
          shrinkToContent: true,
          children: <Widget>[
            _PersonalEntrySheetHeader(
              title: sheetTitle,
              deleteTooltip: l10n.personalEntryDelete,
              onDelete: isEditing && !_busy ? _delete : null,
              onClose: _requestClose,
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
                  GlassFormSectionEyebrow(
                    text: l10n.personalEntryTitleLabel,
                    enabled: true,
                  ),
                  const SizedBox(height: glassSpacingXs),
                  Semantics(
                    key: _titleFieldKey,
                    textField: true,
                    label: l10n.personalEntryTitleLabel,
                    child: TextField(
                      controller: _titleController,
                      onChanged: (value) {
                        if (_titleError != null && value.trim().isNotEmpty) {
                          setState(() => _titleError = null);
                        }
                      },
                      decoration: _glassFieldDecoration(
                        context,
                        hintText: l10n.personalEntryTitleLabel,
                        error: _titleError,
                      ),
                    ),
                  ),
                  const SizedBox(height: glassSpacingLg),
                  SwitchListTile(
                    tileColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.personalEntryAllDayLabel,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                    value: _draft.isAllDay,
                    onChanged: (bool v) {
                      _triggerSelectionHapticFeedback();
                      setState(() {
                        if (v) {
                          _draft = _draft.copyWith(
                            isAllDay: true,
                            startMinutesFromMidnight: null,
                            endMinutesFromMidnight: null,
                          );
                          return;
                        }
                        _draft = _ensureTimeRange(
                          _draft.copyWith(
                            isAllDay: false,
                            startMinutesFromMidnight:
                                _draft.startMinutesFromMidnight,
                            endMinutesFromMidnight:
                                _draft.endMinutesFromMidnight,
                          ),
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
                    dateLabel: _draft.isAllDay
                        ? l10n.personalEntryDateLabel
                        : l10n.personalEntryStartTime,
                    editingEndDate: _editingEndDate,
                    manualEndDate: _manualEndDate,
                    onToggleEndDatePicker: () => _toggleDatePicker(end: true),
                    onAutomaticEndDate: () => setState(() {
                      _manualEndDate = false;
                      _updateAutomaticEndDate();
                    }),
                    timeLabel: l10n.personalDutyTimes,
                    onToggleDatePicker: () => _toggleDatePicker(),
                    onToggleTimePicker: _toggleTimePicker,
                    onDateChanged: (DateTime value) {
                      setState(() {
                        final date = DateTime.utc(
                          value.year,
                          value.month,
                          value.day,
                        );
                        if (_editingEndDate) {
                          _manualEndDate = true;
                          _draft = _draft.copyWith(endDate: date);
                        } else {
                          _draft = _draft.copyWith(date: date);
                          _updateAutomaticEndDate();
                        }
                      });
                    },
                    onSelectStartTime: () =>
                        _setActiveTimeField(_TimeField.start),
                    onSelectEndTime: () => _setActiveTimeField(_TimeField.end),
                    onHourChanged: (int hour) {
                      final bool isApplied = _applyWheelTime(hour: hour);
                      if (isApplied) {
                        _triggerSelectionHapticFeedback();
                      }
                    },
                    onMinuteChanged: (int minuteIndex) {
                      final int minute = _wheelIndexToMinute(minuteIndex);
                      final bool isApplied = _applyWheelTime(minute: minute);
                      if (isApplied) {
                        _triggerSelectionHapticFeedback();
                      }
                    },
                  ),
                  const SizedBox(height: glassSpacingMd),
                  GlassFormSectionEyebrow(
                    text: l10n.personalEntryNotesLabel,
                    enabled: true,
                  ),
                  const SizedBox(height: glassSpacingXs),
                  Semantics(
                    textField: true,
                    label: l10n.personalEntryNotesLabel,
                    child: TextField(
                      controller: _notesController,
                      decoration: _glassFieldDecoration(
                        context,
                        hintText: l10n.personalEntryNotesLabel,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: glassSpacingLg),
                  if (_operationError != null) ...[
                    Semantics(
                      key: _feedbackKey,
                      liveRegion: true,
                      child: GlassCard(
                        padding: const EdgeInsets.all(glassSpacingMd),
                        tintColor: colorScheme.error,
                        tintAlpha: .08,
                        borderColor: colorScheme.error,
                        borderAlpha: .5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: glassSpacingSm),
                            Expanded(
                              child: Text(
                                _operationError!,
                                style: AppFeedbackStyle.text(colorScheme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: glassSpacingMd),
                  ],
                  AppGlassButton(
                    role: AppGlassButtonRole.primary,
                    onPressed: _save,
                    enabled: !_busy,
                    isLoading: _busy,
                    borderRadius: glassSurfaceRadiusSm,
                    height: _kSaveButtonHeight,
                    fullWidth: true,
                    child: Text(
                      l10n.save,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TimeField { start, end }

class _PersonalEntrySheetHeader extends StatelessWidget {
  final String title;
  final String deleteTooltip;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  const _PersonalEntrySheetHeader({
    required this.title,
    required this.deleteTooltip,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 200) onClose();
      },
      child: Padding(
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
            _GlassIconActionChip(
              icon: Icons.close_rounded,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              iconColor: colorScheme.onSurface,
              onTap: onClose,
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
    final scheme = Theme.of(context).colorScheme;
    final Color background = (isDark ? Colors.white : scheme.onSurface)
        .withValues(
          alpha: isDark
              ? kGlassChipUnselectedTintAlphaDark
              : glassModalFillAlphaLight,
        );
    final Color borderColor = (isDark ? Colors.white : scheme.onSurface)
        .withValues(
          alpha: isDark
              ? kGlassChipUnselectedBorderAlphaDark
              : glassModalBorderAlphaLight,
        );
    return AppGlassIconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onTap,
      size: kGlassIconChipSize,
      iconSize: kGlassIconChipIconSize,
      foregroundColor: iconColor,
      tintColor: background,
      borderColor: borderColor,
      shape: liquid.GlassIconButtonShape.roundedSquare,
      borderRadius: kGlassIconChipRadius,
    );
  }
}

class _InlineDateTimeSection extends StatelessWidget {
  final PersonalCalendarEntry draft;
  final _TimeField activeTimeField;
  final bool isDatePickerExpanded;
  final bool isTimePickerExpanded;
  final FixedExtentScrollController hourWheelController;
  final FixedExtentScrollController minuteWheelController;
  final bool editingEndDate;
  final bool manualEndDate;
  final VoidCallback onToggleEndDatePicker;
  final VoidCallback onAutomaticEndDate;
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
    required this.editingEndDate,
    required this.manualEndDate,
    required this.onToggleEndDatePicker,
    required this.onAutomaticEndDate,
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
    return DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(DateTime(value.year, value.month, value.day));
  }

  String _formatTime(BuildContext context, TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(value);
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay startTime = _toTime(
      draft.startMinutesFromMidnight,
      _kDefaultStartMinutes,
    );
    final TimeOfDay endTime = _toTime(
      draft.endMinutesFromMidnight,
      _kDefaultEndMinutes,
    );
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
        GlassFormSectionEyebrow(text: dateLabel, enabled: true),
        const SizedBox(height: glassSpacingXs),
        GlassInlineExpandTile(
          icon: Icons.calendar_today_rounded,
          label: _formatDate(context, draft.date),
          isExpanded: isDatePickerExpanded && !editingEndDate,
          onTap: onToggleDatePicker,
        ),
        if (isTimeEnabled) ...[
          const SizedBox(height: glassSpacingMd),
          GlassFormSectionEyebrow(
            text: AppLocalizations.of(context).personalEntryEndTime,
            enabled: true,
          ),
          const SizedBox(height: glassSpacingXs),
          GlassInlineExpandTile(
            icon: Icons.event_rounded,
            label:
                '${_formatDate(context, draft.endDate ?? draft.date)}${DateUtils.isSameDay(draft.endDate ?? draft.date, DateTime(draft.date.year, draft.date.month, draft.date.day + 1)) ? ' · ${AppLocalizations.of(context).personalDutyNextDay}' : ''}',
            isExpanded: isDatePickerExpanded && editingEndDate,
            onTap: onToggleEndDatePicker,
          ),
          if (manualEndDate)
            TextButton(
              onPressed: onAutomaticEndDate,
              child: Text(
                AppLocalizations.of(context).personalDutyAutomaticEndDate,
              ),
            ),
        ],
        if (isTimeEnabled ||
            Theme.of(context).brightness == Brightness.dark) ...<Widget>[
          const SizedBox(height: glassSpacingMd),
          GlassFormSectionEyebrow(text: timeLabel, enabled: isTimeEnabled),
          const SizedBox(height: glassSpacingXs),
          GlassInlineExpandTile(
            icon: Icons.schedule_rounded,
            label:
                '${_formatTime(context, startTime)} - ${_formatTime(context, endTime)}',
            isExpanded: isTimePickerExpanded && isTimeEnabled,
            enabled: isTimeEnabled,
            onTap: onToggleTimePicker,
          ),
        ],
        if (isDatePickerExpanded) ...<Widget>[
          const SizedBox(height: glassSpacingSm),
          CalendarDatePicker(
            key: ValueKey(editingEndDate),
            initialDate: DateTime(
              (editingEndDate ? draft.endDate ?? draft.date : draft.date).year,
              (editingEndDate ? draft.endDate ?? draft.date : draft.date).month,
              (editingEndDate ? draft.endDate ?? draft.date : draft.date).day,
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
              itemCount: _kMinuteOptionCount,
              onSelectedItemChanged: onMinuteChanged,
              itemBuilder: (int index) =>
                  (index * _kMinuteStep).toString().padLeft(2, '0'),
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
      perspective: _kTimeWheelPerspective,
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
                color: colorScheme.onSurface.withValues(alpha: 1.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<PersonalEntrySheetResult?> showPersonalCalendarEntrySheet({
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
  final key = GlobalKey<_PersonalCalendarEntrySheetState>();
  return Navigator.of(context).push(
    _PersonalEntrySheetRoute(
      requestClose: () => key.currentState?._requestClose(),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: Navigator.of(context).context,
      ),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext ctx) => PersonalCalendarEntrySheet(
        key: key,
        day: day,
        existingSchedule: existingSchedule,
        dutyGroupNameForNew: dutyGroup,
        initialTitle: initialTitle,
      ),
    ),
  );
}

class _PersonalEntrySheetRoute
    extends ModalBottomSheetRoute<PersonalEntrySheetResult> {
  _PersonalEntrySheetRoute({
    required this.requestClose,
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.backgroundColor,
    super.modalBarrierColor,
    super.clipBehavior,
    super.barrierLabel,
  }) : super(enableDrag: false, isDismissible: false);
  final VoidCallback requestClose;
  @override
  Widget buildModalBarrier() => ModalBarrier(
    color: modalBarrierColor,
    dismissible: true,
    onDismiss: requestClose,
    semanticsLabel: barrierLabel,
  );
}
