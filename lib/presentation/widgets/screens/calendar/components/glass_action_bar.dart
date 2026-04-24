import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';

/// Floating, glass-morphic action bar pinned above the bottom safe area.
///
/// Hosts the main actions of the calendar screen:
/// 1. Quick-add appointment title field (submit opens the personal entry sheet)
/// 2. Add button (opens the personal entry sheet for the selected day)
/// 3. Jump to today
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

  void _showPersonalEntrySheet({String? initialTitle}) {
    final BuildContext ctx = context;
    final DateTime day =
        ref.read(scheduleCoordinatorProvider).value?.selectedDay ??
        DateTime.now();
    showPersonalCalendarEntrySheet(
      context: ctx,
      ref: ref,
      day: day,
      existingSchedule: null,
      initialTitle: initialTitle,
    );
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
    _quickTitleController.clear();
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(width: 8),
              _AddPersonalEntryAction(
                palette: palette,
                tooltip: l10n.addPersonalEntryTooltip,
                onPressed: () {
                  _quickTitleFocusNode.unfocus();
                  _showPersonalEntrySheet();
                },
              ),
              const SizedBox(width: 8),
              _TodayAction(
                palette: palette,
                tooltip: l10n.today,
                onPressed: () {
                  ref.read(scheduleCoordinatorProvider.notifier).goToToday();
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
    final Locale locale = Localizations.localeOf(context);
    final String loc = locale.toString();
    if (locale.languageCode == 'de') {
      return DateFormat('d.M.', loc).format(day);
    }
    return DateFormat.Md(loc).format(day);
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
        style: TextStyle(
          color: palette.fieldTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        cursorColor: palette.fieldCursorColor,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: palette.fieldHintColor,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          filled: true,
          fillColor: palette.fieldFillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: palette.fieldBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: palette.fieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
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
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.addActionFillColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: palette.addActionBorderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: palette.addActionIconColor,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayAction extends StatelessWidget {
  final _GlassActionBarPalette palette;
  final String tooltip;
  final VoidCallback onPressed;

  const _TodayAction({
    required this.palette,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.todayActionFillColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: palette.todayActionBorderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.today_rounded,
                color: palette.todayActionIconColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassActionBarPalette {
  final Color fieldTextColor;
  final Color fieldHintColor;
  final Color fieldCursorColor;
  final Color fieldFillColor;
  final Color fieldBorderColor;
  final Color fieldFocusedBorderColor;
  final Color addActionFillColor;
  final Color addActionBorderColor;
  final Color addActionIconColor;
  final Color todayActionFillColor;
  final Color todayActionBorderColor;
  final Color todayActionIconColor;

  const _GlassActionBarPalette({
    required this.fieldTextColor,
    required this.fieldHintColor,
    required this.fieldCursorColor,
    required this.fieldFillColor,
    required this.fieldBorderColor,
    required this.fieldFocusedBorderColor,
    required this.addActionFillColor,
    required this.addActionBorderColor,
    required this.addActionIconColor,
    required this.todayActionFillColor,
    required this.todayActionBorderColor,
    required this.todayActionIconColor,
  });

  factory _GlassActionBarPalette.fromTheme(ThemeData themeData) {
    final ColorScheme colorScheme = themeData.colorScheme;
    final bool isDark = themeData.brightness == Brightness.dark;
    return _GlassActionBarPalette(
      fieldTextColor: colorScheme.onSurface.withValues(alpha: 0.94),
      fieldHintColor: colorScheme.onSurface.withValues(
        alpha: isDark ? 0.60 : 0.52,
      ),
      fieldCursorColor: colorScheme.onSurface.withValues(alpha: 0.96),
      fieldFillColor: Colors.white.withValues(alpha: isDark ? 0.10 : 0.20),
      fieldBorderColor: Colors.white.withValues(alpha: isDark ? 0.22 : 0.40),
      fieldFocusedBorderColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.78 : 0.62,
      ),
      addActionFillColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.24 : 0.20,
      ),
      addActionBorderColor: colorScheme.primary.withValues(
        alpha: isDark ? 0.70 : 0.62,
      ),
      addActionIconColor: colorScheme.onSurface.withValues(alpha: 0.96),
      todayActionFillColor: Colors.white.withValues(
        alpha: isDark ? 0.10 : 0.22,
      ),
      todayActionBorderColor: Colors.white.withValues(
        alpha: isDark ? 0.22 : 0.42,
      ),
      todayActionIconColor: colorScheme.onSurface.withValues(alpha: 0.92),
    );
  }
}
