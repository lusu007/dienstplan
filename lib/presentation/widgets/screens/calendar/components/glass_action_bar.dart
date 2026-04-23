import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/domain/entities/duty_group.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';

/// Floating, glass-morphic action bar pinned above the bottom safe area.
///
/// Hosts the three main actions of the calendar screen:
/// 1. Duty group filter chip (active group or "All")
/// 2. Partner duty group toggle
/// 3. Jump to today
class GlassActionBar extends ConsumerWidget {
  const GlassActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
    final String? selectedDutyGroup = state?.selectedDutyGroup;
    final String? partnerDutyGroup = state?.partnerDutyGroup;
    final String? partnerConfigName = state?.partnerConfigName;
    final bool partnerConfigured =
        (partnerConfigName?.isNotEmpty ?? false) &&
        (partnerDutyGroup?.isNotEmpty ?? false);
    final bool partnerVisible = ref.watch(calendarPartnerVisibilityProvider);
    final List<DutyGroup> activeGroups =
        state?.activeConfig?.dutyGroups ?? const <DutyGroup>[];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _FilterChipAction(
                  selectedDutyGroup: selectedDutyGroup,
                  availableGroups: activeGroups,
                  onSelected: (String? group) async {
                    await ref
                        .read(scheduleCoordinatorProvider.notifier)
                        .setSelectedDutyGroup(group);
                  },
                ),
              ),
              const SizedBox(width: 8),
              _PartnerToggleAction(
                partnerConfigured: partnerConfigured,
                partnerVisible: partnerVisible,
                tooltip: l10n.partnerDutyGroup,
                onToggleVisibility: () {
                  ref.read(calendarPartnerVisibilityProvider.notifier).toggle();
                },
                onConfigure: () => context.router.push(const SettingsRoute()),
              ),
              const SizedBox(width: 4),
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
}

class _FilterChipAction extends StatelessWidget {
  final String? selectedDutyGroup;
  final List<DutyGroup> availableGroups;
  final ValueChanged<String?> onSelected;

  const _FilterChipAction({
    required this.selectedDutyGroup,
    required this.availableGroups,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isFiltering =
        selectedDutyGroup != null && selectedDutyGroup!.isNotEmpty;
    final String label = isFiltering ? selectedDutyGroup! : l10n.all;
    final bool canFilter = availableGroups.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: canFilter ? () => _openPicker(context, l10n) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isFiltering ? 0.35 : 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${l10n.filteredBy}: $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.filteredBy,
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.clear_all_rounded),
                title: Text(l10n.all),
                selected:
                    selectedDutyGroup == null || selectedDutyGroup!.isEmpty,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelected(null);
                },
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableGroups.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DutyGroup group = availableGroups[index];
                    final bool isSelected = group.name == selectedDutyGroup;
                    return ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: Text(group.name),
                      selected: isSelected,
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onSelected(group.name);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _PartnerToggleAction extends StatelessWidget {
  final bool partnerConfigured;
  final bool partnerVisible;
  final String tooltip;
  final VoidCallback onToggleVisibility;
  final VoidCallback onConfigure;

  const _PartnerToggleAction({
    required this.partnerConfigured,
    required this.partnerVisible,
    required this.tooltip,
    required this.onToggleVisibility,
    required this.onConfigure,
  });

  bool get _isVisuallyActive => partnerConfigured && partnerVisible;

  @override
  Widget build(BuildContext context) {
    final Color foreground = Colors.white.withValues(
      alpha: _isVisuallyActive ? 1.0 : 0.55,
    );
    final Color background = _isVisuallyActive
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.0);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _handleTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(Icons.group_rounded, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    if (!partnerConfigured) {
      onConfigure();
      return;
    }
    onToggleVisibility();
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
