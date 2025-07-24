import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

import 'package:dienstplan/presentation/widgets/screens/calendar/utils/schedule_list_animation_mixin.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_item_list.dart';

class DutyScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final bool shouldAnimate;
  final Map<String, DutyType>? dutyTypes;
  final List<String>? dutyTypeOrder;
  final String? activeConfigName;
  final bool isLoading;

  const DutyScheduleList({
    super.key,
    required this.schedules,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
    this.shouldAnimate = false,
    this.dutyTypes,
    this.dutyTypeOrder,
    this.activeConfigName,
    this.isLoading = false,
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
    if (widget.shouldAnimate && !oldWidget.shouldAnimate && !hasAnimated) {
      triggerAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  List<Schedule> _getFilteredSchedules() {
    return widget.schedules.where((schedule) {
      final isActiveConfig = widget.activeConfigName == null ||
          schedule.configName == widget.activeConfigName;
      final isSelectedDutyGroup = widget.selectedDutyGroup == null ||
          schedule.dutyGroupName == widget.selectedDutyGroup;
      return isActiveConfig && isSelectedDutyGroup;
    }).toList();
  }

  List<Schedule> _sortSchedules(List<Schedule> schedules) {
    if (widget.dutyTypeOrder == null || widget.dutyTypeOrder!.isEmpty) {
      return schedules;
    }

    return List.from(schedules)
      ..sort((a, b) {
        final aIndex = widget.dutyTypeOrder!.indexOf(a.dutyTypeId);
        final bIndex = widget.dutyTypeOrder!.indexOf(b.dutyTypeId);

        if (aIndex != -1 && bIndex != -1) {
          return aIndex.compareTo(bIndex);
        }
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;
        return a.dutyTypeId.compareTo(b.dutyTypeId);
      });
  }

  void _onDutyGroupSelected(String? dutyGroupId) {
    widget.onDutyGroupSelected?.call(dutyGroupId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || widget.schedules.isEmpty) {
      return _buildSkeletonLoader();
    }

    final filteredSchedules = _getFilteredSchedules();

    if (filteredSchedules.isEmpty) {
      return _buildEmptyState();
    }

    final sortedSchedules = _sortSchedules(filteredSchedules);
    final dutyListContent = _buildDutyList(sortedSchedules);

    return widget.shouldAnimate
        ? buildAnimatedContent(dutyListContent)
        : dutyListContent;
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return DutyItemUiBuilder.buildEmptyState(l10n.noServicesForDay);
  }

  Widget _buildDutyList(List<Schedule> schedules) {
    return DutyItemList(
      schedules: schedules,
      selectedDutyGroupName: widget.selectedDutyGroup,
      onDutyGroupSelected: _onDutyGroupSelected,
      scrollController: widget.scrollController,
      dutyTypes: widget.dutyTypes,
      showFilterStatus: false,
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 72,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
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
    );
  }
}
