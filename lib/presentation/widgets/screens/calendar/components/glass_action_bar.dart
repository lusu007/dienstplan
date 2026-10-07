import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';

/// Floating, glass-morphic action bar pinned above the bottom safe area.
///
/// Hosts the main actions of the calendar screen:
/// 1. Quick-add appointment title field (submit opens the personal entry sheet)
/// 2. Add button (opens the personal entry sheet for the selected day)
class GlassActionBar extends ConsumerStatefulWidget {
  const GlassActionBar({super.key});

  @override
  ConsumerState<GlassActionBar> createState() => _GlassActionBarState();
}

class _GlassActionBarState extends ConsumerState<GlassActionBar> {
  late final TextEditingController _quickTitleController;
  late final FocusNode _quickTitleFocusNode;

  @override
  void initState() {
    super.initState();
    _quickTitleController = TextEditingController();
    // Avoid opening the keyboard (and calendar compact mode) on screen load;
    // the field only requests focus after the user taps it. See _onQuickFieldFocusChange.
    _quickTitleFocusNode = FocusNode(canRequestFocus: false);
    _quickTitleFocusNode.addListener(_onQuickFieldFocusChange);
  }

  void _onQuickFieldFocusChange() {
    if (!mounted) {
      return;
    }
    if (!_quickTitleFocusNode.hasFocus) {
      _quickTitleFocusNode.canRequestFocus = false;
    }
  }

  @override
  void dispose() {
    _quickTitleFocusNode.removeListener(_onQuickFieldFocusChange);
    _quickTitleController.dispose();
    _quickTitleFocusNode.dispose();
    super.dispose();
  }

  bool _openingEntry = false;

  Future<void> _showPersonalEntrySheet({String? initialTitle}) async {
    if (_openingEntry) return;
    _openingEntry = true;
    final BuildContext ctx = context;
    final DateTime day =
        ref.read(scheduleCoordinatorProvider).value?.selectedDay ??
        DateTime.now();
    final result = await showPersonalCalendarEntrySheet(
      context: ctx,
      ref: ref,
      day: day,
      existingSchedule: null,
      initialTitle: initialTitle ?? _quickTitleController.text.trim(),
    );
    _openingEntry = false;
    if (mounted && result == PersonalEntrySheetResult.saved) {
      _quickTitleController.clear();
    }
  }

  void _onQuickFieldTap() {
    _quickTitleFocusNode.canRequestFocus = true;
    _quickTitleFocusNode.requestFocus();
  }

  void _onQuickTitleSubmitted(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _showPersonalEntrySheet(initialTitle: trimmed);
    _quickTitleFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final _GlassActionBarPalette palette = _GlassActionBarPalette.fromTheme(
      Theme.of(context),
    );
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final DateTime quickEntryDay = state?.selectedDay ?? DateTime.now();
    final DateTime dayOnly = DateTime(
      quickEntryDay.year,
      quickEntryDay.month,
      quickEntryDay.day,
    );
    final String dateLabel = _formatQuickHintDate(context, dayOnly);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingLg,
          0,
          glassSpacingLg,
          glassSpacingMd,
        ),
        child: AppGlassSurface(
          borderRadius: 32,
          tint: palette.barTint,
          borderColor: palette.barBorder,
          padding: const EdgeInsets.all(glassSpacingSm),
          child: Row(
            children: [
              Expanded(
                child: _QuickPersonalEntryField(
                  controller: _quickTitleController,
                  focusNode: _quickTitleFocusNode,
                  onTap: _onQuickFieldTap,
                  palette: palette,
                  hintText: l10n.personalEntryQuickTitleHint(dateLabel),
                  semanticLabel: l10n.personalEntryQuickTitleSemanticLabel(
                    dateLabel,
                  ),
                  onSubmitted: _onQuickTitleSubmitted,
                ),
              ),
              const SizedBox(width: glassSpacingSm),
              _AddPersonalEntryAction(
                palette: palette,
                tooltip: l10n.addPersonalEntryTooltip,
                onPressed: () {
                  _quickTitleFocusNode.unfocus();
                  _showPersonalEntrySheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact date for the action-bar hint (keeps string short).
  static String _formatQuickHintDate(BuildContext context, DateTime day) {
    final String loc = Localizations.localeOf(context).toString();
    return DateFormat('d.M.', loc).format(day);
  }
}

class _QuickPersonalEntryField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final _GlassActionBarPalette palette;
  final String hintText;
  final String semanticLabel;
  final ValueChanged<String> onSubmitted;

  const _QuickPersonalEntryField({
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.palette,
    required this.hintText,
    required this.semanticLabel,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? baseStyle = Theme.of(context).textTheme.bodyMedium;
    final TextStyle textStyle = (baseStyle ?? const TextStyle()).copyWith(
      color: palette.fieldTextColor,
      fontWeight: FontWeight.w600,
    );
    final TextStyle hintStyle = (baseStyle ?? const TextStyle()).copyWith(
      color: palette.fieldHintColor,
      fontWeight: FontWeight.w500,
    );
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onTap: onTap,
        onTapOutside: (PointerDownEvent event) {
          focusNode.unfocus();
        },
        style: textStyle,
        cursorColor: palette.fieldCursorColor,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: hintStyle,
          filled: false,
          constraints: const BoxConstraints(minHeight: _kActionButtonSize),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: glassSpacingMd,
            vertical: glassSpacingMd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kActionButtonRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kActionButtonRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kActionButtonRadius),
            borderSide: BorderSide(color: palette.fieldFocusedBorderColor),
          ),
        ),
      ),
    );
  }
}

class _AddPersonalEntryAction extends StatelessWidget {
  final _GlassActionBarPalette palette;
  final String tooltip;
  final VoidCallback onPressed;

  const _AddPersonalEntryAction({
    required this.palette,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassIconButton(
      icon: Icons.add_rounded,
      tooltip: tooltip,
      onPressed: onPressed,
      size: _kActionButtonSize,
      iconSize: 24,
      tintColor: palette.addActionFillColor,
      borderColor: palette.addActionBorderColor,
      foregroundColor: palette.addActionIconColor,
    );
  }
}

const double _kActionButtonSize = 48;
const double _kActionButtonRadius = _kActionButtonSize / 2;

class _GlassActionBarPalette {
  final Color fieldTextColor;
  final Color fieldHintColor;
  final Color fieldCursorColor;
  final Color barTint;
  final Color barBorder;
  final Color fieldFocusedBorderColor;
  final Color addActionFillColor;
  final Color addActionBorderColor;
  final Color addActionIconColor;

  const _GlassActionBarPalette({
    required this.fieldTextColor,
    required this.fieldHintColor,
    required this.fieldCursorColor,
    required this.barTint,
    required this.barBorder,
    required this.fieldFocusedBorderColor,
    required this.addActionFillColor,
    required this.addActionBorderColor,
    required this.addActionIconColor,
  });

  factory _GlassActionBarPalette.fromTheme(ThemeData themeData) {
    final ColorScheme colorScheme = themeData.colorScheme;
    final bool isDark = themeData.brightness == Brightness.dark;
    return _GlassActionBarPalette(
      fieldTextColor: colorScheme.onSurface.withValues(alpha: 0.94),
      fieldHintColor: colorScheme.onSurface.withValues(
        alpha: isDark ? 0.72 : 0.68,
      ),
      fieldCursorColor: colorScheme.onSurface.withValues(alpha: 0.96),
      barTint: colorScheme.surface.withValues(alpha: isDark ? 0.18 : 0.30),
      barBorder: colorScheme.onSurface.withValues(alpha: isDark ? 0.18 : 0.12),
      fieldFocusedBorderColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.78 : 0.62,
      ),
      addActionFillColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.38 : 0.28,
      ),
      addActionBorderColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.46 : 0.36,
      ),
      addActionIconColor: colorScheme.onSurface.withValues(alpha: 0.96),
    );
  }
}
