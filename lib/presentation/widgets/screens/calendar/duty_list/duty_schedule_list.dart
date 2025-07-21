import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';

import 'package:dienstplan/presentation/widgets/screens/calendar/utils/schedule_list_animation_mixin.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_list.dart';

class DutyScheduleList extends StatefulWidget {
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
  final bool isLoading; // Add loading state parameter

  const DutyScheduleList({
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
    this.isLoading = false, // Default to false
  });

  @override
  State<DutyScheduleList> createState() => _DutyScheduleListState();
}

class _DutyScheduleListState extends State<DutyScheduleList>
    with TickerProviderStateMixin, ScheduleListAnimationMixin {
  @override
  void initState() {
    super.initState();
    initializeAnimations(this);
  }

  @override
  void didUpdateWidget(DutyScheduleList oldWidget) {
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
        final isSelectedDutyGroup = widget.selectedDutyGroup == null ||
            schedule.dutyGroupName == widget.selectedDutyGroup;
        final isActiveConfig = widget.activeConfigName == null ||
            schedule.configName == widget.activeConfigName;

        return isSelectedDutyGroup && isActiveConfig;
      }).toList();

      return filteredSchedules;
    } catch (e, stackTrace) {
      AppLogger.e('DutyScheduleList: Error filtering schedules', e, stackTrace);
      return [];
    }
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    try {
      if (widget.onDutyGroupSelected != null) {
        widget.onDutyGroupSelected!(dutyGroupId);
      }
    } catch (e, stackTrace) {
      AppLogger.e('DutyScheduleList: Error updating duty group selection', e,
          stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    try {
      // Show skeleton loader if loading or if no schedules available
      if (widget.isLoading || widget.schedules.isEmpty) {
        return _buildSkeletonLoader();
      }

      final sortedSchedules = _getFilteredAndSortedSchedules();

      if (sortedSchedules.isEmpty) {
        return DutyItemUiBuilder.buildEmptyState(l10n.noServicesForDay);
      }

      // Get schedules for the duty list (show all duties for the selected day, not filtered by duty group)
      final dutyListSchedules = widget.schedules.where((schedule) {
        final isActiveConfig = widget.activeConfigName == null ||
            schedule.configName == widget.activeConfigName;
        final isSelectedDutyGroup = widget.selectedDutyGroup == null ||
            schedule.dutyGroupName == widget.selectedDutyGroup;

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
            child: DutyItemList(
              schedules: dutyListSchedules,
              selectedDutyGroupName: widget.selectedDutyGroup,
              onDutyGroupSelected: _onDutyGroupSelected,
              scrollController: widget.scrollController,
              selectedDay: widget.selectedDay,
              dutyTypes: widget.dutyTypes,
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      AppLogger.e('DutyScheduleList: Error in build method', e, stackTrace);

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

  Widget _buildSkeletonLoader() {
    final l10n = AppLocalizations.of(context);
    final filterStatusText =
        widget.selectedDutyGroup != null && widget.selectedDutyGroup!.isNotEmpty
            ? '${l10n.filteredBy}: ${widget.selectedDutyGroup}'
            : '${l10n.filteredBy}: ${l10n.all}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with real filter status text (no skeleton)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            filterStatusText,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        // Duty items skeleton
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            itemCount: 5, // Show 5 skeleton items
            itemBuilder: (context, index) => _buildSkeletonDutyItem(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonDutyItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Skeleton icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            // Skeleton text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
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
