import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/calendar_export_service.dart';
import 'package:dienstplan/domain/entities/calendar_export_options.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_icon_badge.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarExportBottomsheet extends ConsumerStatefulWidget {
  static const double _defaultHeightPercentage = 0.76;

  final double heightPercentage;

  const CalendarExportBottomsheet({
    super.key,
    this.heightPercentage = _defaultHeightPercentage,
  });

  static Future<void> show(
    BuildContext context, {
    double heightPercentage = _defaultHeightPercentage,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CalendarExportBottomsheet(heightPercentage: heightPercentage),
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
  bool _isActionBusy = false;
  CalendarExportPreparedResult? _cachedPrepared;
  _CalendarExportCacheKey? _cacheKey;

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
    return GenericBottomsheet(
      title: l10n.exportCalendar,
      heightPercentage: widget.heightPercentage,
      children: [_buildSheetContent(context)],
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsProvider).value;
    final hasPartnerSchedule =
        (settingsState?.partnerConfigName?.isNotEmpty ?? false) &&
        (settingsState?.partnerDutyGroup?.isNotEmpty ?? false);
    final effectiveIncludePartner =
        hasPartnerSchedule && _includePartnerSchedule;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.exportCalendarDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                    onSelected: (value) => setState(() {
                      _startDate = value;
                      _invalidatePreparedCache();
                    }),
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
                    onSelected: (value) => setState(() {
                      _endDate = value;
                      _invalidatePreparedCache();
                    }),
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
                    if (!hasPartnerSchedule) return;
                    setState(() {
                      _includePartnerSchedule = value;
                      _invalidatePreparedCache();
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: bottomInset + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CalendarExportActionButtonGroup(
                enabled: !_isActionBusy,
                mainColor: Theme.of(context).colorScheme.primary,
                segments: [
                  _CalendarExportActionSegment(
                    icon: Icons.ios_share_outlined,
                    title: l10n.exportCalendarActionRowShare,
                    tooltip:
                        '${l10n.exportCalendarActionShare}: ${l10n.exportCalendarActionShareSubtitle}',
                    onTap: _exportAndShare,
                  ),
                  _CalendarExportActionSegment(
                    icon: Icons.save_alt_outlined,
                    title: l10n.exportCalendarActionRowSave,
                    tooltip:
                        '${l10n.exportCalendarActionSave}: ${l10n.exportCalendarActionSaveSubtitle}',
                    onTap: _exportAndSave,
                  ),
                  _CalendarExportActionSegment(
                    icon: Icons.event_outlined,
                    title: l10n.exportCalendarActionRowOpen,
                    tooltip:
                        '${l10n.exportCalendarActionOpen}: ${l10n.exportCalendarActionOpenSubtitle}',
                    onTap: _exportAndOpen,
                  ),
                ],
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

  void _invalidatePreparedCache() {
    _cachedPrepared = null;
    _cacheKey = null;
  }

  Future<CalendarExportPreparedResult?> _ensurePreparedFile(
    AppLocalizations l10n,
    ScaffoldMessengerState messenger,
  ) async {
    final settingsState = ref.read(settingsProvider).value;
    final hasPartnerSchedule =
        (settingsState?.partnerConfigName?.isNotEmpty ?? false) &&
        (settingsState?.partnerDutyGroup?.isNotEmpty ?? false);
    final includePartnerSchedule =
        hasPartnerSchedule && _includePartnerSchedule;

    if (_startDate.isAfter(_endDate)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportCalendarInvalidRange)),
      );
      return null;
    }

    final cacheKey = _CalendarExportCacheKey(
      startDate: DateTime.utc(
        _startDate.year,
        _startDate.month,
        _startDate.day,
      ),
      endDate: DateTime.utc(_endDate.year, _endDate.month, _endDate.day),
      includePartner: includePartnerSchedule,
    );
    if (_cacheKey == cacheKey && _cachedPrepared != null) {
      return _cachedPrepared;
    }

    try {
      final generateExportUseCase = await ref.read(
        generateCalendarExportUseCaseProvider.future,
      );
      final exportResult = await generateExportUseCase.execute(
        CalendarExportOptions(
          startDate: _startDate,
          endDate: _endDate,
          includePartnerSchedule: includePartnerSchedule,
          partnerSummaryPrefix: l10n.exportCalendarPartnerSummaryPrefix,
        ),
      );

      if (exportResult.isFailure) {
        if (!mounted) return null;
        messenger.showSnackBar(
          SnackBar(
            content: Text(_resolveFailureMessage(exportResult.failure, l10n)),
          ),
        );
        return null;
      }

      final calendarExportService = ref.read(calendarExportServiceProvider);
      final writeResult = await calendarExportService.writeCalendarExportToTemp(
        exportResult.value,
      );

      if (writeResult.isFailure) {
        if (!mounted) return null;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportCalendarError)),
        );
        return null;
      }

      _cacheKey = cacheKey;
      _cachedPrepared = writeResult.value;
      return writeResult.value;
    } catch (error, stackTrace) {
      AppLogger.e(
        'Calendar export failed (startDate=${_startDate.toIso8601String()}, endDate=${_endDate.toIso8601String()}, includePartner=$includePartnerSchedule, reason=unexpected_ui_error)',
        error,
        stackTrace,
      );
      if (!mounted) return null;
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportCalendarError)));
      return null;
    }
  }

  Future<void> _exportAndShare() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isActionBusy = true);
    try {
      final prepared = await _ensurePreparedFile(l10n, messenger);
      if (!mounted || prepared == null) return;
      final calendarExportService = ref.read(calendarExportServiceProvider);
      final result = await calendarExportService.sharePreparedCalendarExport(
        filePath: prepared.filePath,
        entryCount: prepared.entryCount,
        l10n: l10n,
      );
      if (!mounted) return;
      if (result.isFailure) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportCalendarError)),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportCalendarShareSuccess)),
      );
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  Future<void> _exportAndSave() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isActionBusy = true);
    try {
      final prepared = await _ensurePreparedFile(l10n, messenger);
      if (!mounted || prepared == null) return;
      final calendarExportService = ref.read(calendarExportServiceProvider);
      final result = await calendarExportService.savePreparedCalendarExport(
        filePath: prepared.filePath,
        fileName: prepared.fileName,
        entryCount: prepared.entryCount,
      );
      if (!mounted) return;
      if (result.isFailure) {
        messenger.showSnackBar(
          SnackBar(content: Text(_resolveFailureMessage(result.failure, l10n))),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportCalendarSaveSuccess)),
      );
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  Future<void> _exportAndOpen() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isActionBusy = true);
    try {
      final prepared = await _ensurePreparedFile(l10n, messenger);
      if (!mounted || prepared == null) return;
      final calendarExportService = ref.read(calendarExportServiceProvider);
      final result = await calendarExportService.openPreparedCalendarExport(
        filePath: prepared.filePath,
        entryCount: prepared.entryCount,
      );
      if (!mounted) return;
      if (result.isFailure) {
        messenger.showSnackBar(
          SnackBar(content: Text(_resolveFailureMessage(result.failure, l10n))),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportCalendarOpenSuccess)),
      );
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
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
      case 'calendarExportEmpty':
        return l10n.exportCalendarEmpty;
      case 'calendarExportSaveCancelled':
        return l10n.exportCalendarSaveCancelled;
      case 'calendarExportOpenNoApp':
        return l10n.exportCalendarOpenNoApp;
      case 'calendarExportOpenFailed':
        return l10n.exportCalendarOpenFailed;
      default:
        return l10n.exportCalendarError;
    }
  }
}

@immutable
class _CalendarExportCacheKey {
  final DateTime startDate;
  final DateTime endDate;
  final bool includePartner;

  const _CalendarExportCacheKey({
    required this.startDate,
    required this.endDate,
    required this.includePartner,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CalendarExportCacheKey &&
          startDate.year == other.startDate.year &&
          startDate.month == other.startDate.month &&
          startDate.day == other.startDate.day &&
          endDate.year == other.endDate.year &&
          endDate.month == other.endDate.month &&
          endDate.day == other.endDate.day &&
          includePartner == other.includePartner;

  @override
  int get hashCode => Object.hash(
    startDate.year,
    startDate.month,
    startDate.day,
    endDate.year,
    endDate.month,
    endDate.day,
    includePartner,
  );
}

class _CalendarExportActionSegment {
  final IconData icon;
  final String title;
  final String tooltip;
  final VoidCallback onTap;

  const _CalendarExportActionSegment({
    required this.icon,
    required this.title,
    required this.tooltip,
    required this.onTap,
  });
}

/// Single outlined control: three labeled actions with shared border (button group).
class _CalendarExportActionButtonGroup extends StatelessWidget {
  /// Fixed row height: parent Column may pass unbounded vertical constraints
  /// (Expanded scroll area + bottom actions). [VerticalDivider] needs a
  /// bounded height; single title line under each icon.
  static const double _actionRowHeight = 88;

  final bool enabled;
  final Color mainColor;
  final List<_CalendarExportActionSegment> segments;

  const _CalendarExportActionButtonGroup({
    required this.enabled,
    required this.mainColor,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = mainColor;
    final Color mutedColor = mainColor.withValues(alpha: 0.38);
    final Color fg = enabled ? activeColor : mutedColor;

    return SizedBox(
      height: _actionRowHeight,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: mainColor),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < segments.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: mainColor.withValues(alpha: 0.35),
                ),
              Expanded(
                child: Tooltip(
                  message: segments[i].tooltip,
                  child: Semantics(
                    button: true,
                    label: segments[i].tooltip,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: enabled ? segments[i].onTap : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(segments[i].icon, size: 24, color: fg),
                              const SizedBox(height: 6),
                              Text(
                                segments[i].title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: enabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.38,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
    return GlassCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            GlassIconBadge(icon: icon),
            const SizedBox(width: 14),
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
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
    return GlassCard(
      enabled: enabled,
      child: SwitchListTile(
        value: value,
        onChanged: enabled
            ? (bool nextValue) {
                HapticFeedback.selectionClick();
                onChanged(nextValue);
              }
            : null,
        title: Text(title),
        subtitle: Text(subtitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
