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
                  hintText: l10n.personalEntryQuickTitleHint(dateLabel),
                  semanticLabel: l10n.personalEntryQuickTitleSemanticLabel(
                    dateLabel,
                  ),
                  onSubmitted: _onQuickTitleSubmitted,
                ),
              ),
              const SizedBox(width: 8),
              _AddPersonalEntryAction(
                tooltip: l10n.addPersonalEntryTooltip,
                onPressed: () {
                  _quickTitleFocusNode.unfocus();
                  _showPersonalEntrySheet();
                },
              ),
              const SizedBox(width: 8),
              _TodayAction(
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
  final String hintText;
  final String semanticLabel;
  final ValueChanged<String> onSubmitted;

  const _QuickPersonalEntryField({
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.hintText,
    required this.semanticLabel,
    required this.onSubmitted,
  });

  static const TextStyle _textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

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
        style: _textStyle,
        cursorColor: Colors.white,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: _textStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
          ),
        ),
      ),
    );
  }
}

class _AddPersonalEntryAction extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _AddPersonalEntryAction({
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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
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
  final String tooltip;
  final VoidCallback onPressed;

  const _TodayAction({required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.today_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
