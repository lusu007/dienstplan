import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

import 'package:dienstplan/presentation/widgets/extra_widgets/layout/schedule_list_animation_mixin.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/layout/schedule_list_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/layout/schedule_item_widget.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/layout/duty_list_widget.dart';

class ScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final List<String>? dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final bool shouldAnimate;
  final DateTime? selectedDay;
  final Map<String, DutyType>? dutyTypes;
  final List<String>? dutyTypeOrder;
  final String? activeConfigName;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
    this.shouldAnimate = false,
    this.selectedDay,
    this.dutyTypes,
    this.dutyTypeOrder,
    this.activeConfigName,
  });

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList>
    with TickerProviderStateMixin, ScheduleListAnimationMixin {
  String? _selectedDutyGroup;

  @override
  void initState() {
    super.initState();
    initializeAnimations(this);
  }

  @override
  void didUpdateWidget(ScheduleList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if shouldAnimate is true and we haven't animated yet
    if (widget.shouldAnimate && !oldWidget.shouldAnimate && !hasAnimated) {
      triggerAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  List<Schedule> _getFilteredAndSortedSchedules() {
    try {
      // Since we now receive schedulesForSelectedDay, we only need to filter by duty group and config
      final filteredSchedules = widget.schedules.where((schedule) {
        final isSelectedDutyGroup = _selectedDutyGroup == null ||
            schedule.dutyGroupName == _selectedDutyGroup;
        final isActiveConfig = widget.activeConfigName == null ||
            schedule.configName == widget.activeConfigName;

        return isSelectedDutyGroup && isActiveConfig;
      }).toList();

      return filteredSchedules;
    } catch (e, stackTrace) {
      print(
          'ERROR _getFilteredAndSortedSchedules: Error filtering schedules: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    try {
      setState(() {
        _selectedDutyGroup = dutyGroupId;
      });
    } catch (e, stackTrace) {
      print(
          'ERROR _onDutyGroupSelected: Error updating duty group selection: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    try {
      final sortedSchedules = _getFilteredAndSortedSchedules();

      if (sortedSchedules.isEmpty) {
        return ScheduleListUiBuilder.buildEmptyState(l10n.noServicesForDay);
      }

      // Get schedules for the duty list (show all duties for the selected day, not filtered by duty group)
      final dutyListSchedules = widget.schedules.where((schedule) {
        final isActiveConfig = widget.activeConfigName == null ||
            schedule.configName == widget.activeConfigName;
        final isSelectedDutyGroup = _selectedDutyGroup == null ||
            schedule.dutyGroupName == _selectedDutyGroup;

        // Show all duties for the selected day, but filter by duty group if selected
        return isActiveConfig && isSelectedDutyGroup;
      }).toList();

      // Sort schedules by duty_type_order from JSON configuration
      if (widget.dutyTypeOrder != null && widget.dutyTypeOrder!.isNotEmpty) {
        dutyListSchedules.sort((a, b) {
          final aIndex = widget.dutyTypeOrder!.indexOf(a.dutyTypeId);
          final bIndex = widget.dutyTypeOrder!.indexOf(b.dutyTypeId);

          // If both duty types are in the order list, sort by their position
          if (aIndex != -1 && bIndex != -1) {
            return aIndex.compareTo(bIndex);
          }

          // If only one is in the order list, prioritize the one that is
          if (aIndex != -1) return -1;
          if (bIndex != -1) return 1;

          // If neither is in the order list, sort alphabetically
          return a.dutyTypeId.compareTo(b.dutyTypeId);
        });
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duty list widget
          Expanded(
            child: DutyListWidget(
              schedules: dutyListSchedules,
              selectedDutyGroupName: _selectedDutyGroup,
              onDutyGroupSelected: _onDutyGroupSelected,
              scrollController: widget.scrollController,
              selectedDay: widget.selectedDay,
              dutyTypes: widget.dutyTypes,
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      print('ERROR ScheduleList: Error in build method: $e');
      print('Stack trace: $stackTrace');

      // Return a safe fallback widget
      return Center(
        child: Text(
          'Error loading schedules',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red.shade600,
          ),
        ),
      );
    }
  }
}
