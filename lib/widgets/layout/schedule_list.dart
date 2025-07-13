import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/models/schedule.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/utils/icon_mapper.dart';

class ScheduleList extends StatefulWidget {
  final List<Schedule> schedules;
  final List<String>? dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final ScrollController? scrollController;
  final bool shouldAnimate;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.scrollController,
    this.shouldAnimate = false,
  });

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<Schedule> _currentSchedules = [];
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(ScheduleList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only animate if shouldAnimate is true and we haven't animated yet
    if (widget.shouldAnimate && !oldWidget.shouldAnimate && !_hasAnimated) {
      _hasAnimated = true;
      _animationController.reset();
      _animationController.forward();

      // Reset the flag after animation completes
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            _hasAnimated = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Schedule> _getFilteredAndSortedSchedules() {
    final filteredSchedules = _filterSchedules(widget.schedules);
    return _sortSchedulesByTime(filteredSchedules);
  }

  List<Schedule> _sortSchedulesByTime(List<Schedule> schedules) {
    return List.from(schedules)
      ..sort((a, b) {
        // Sort by all-day status (all-day services go last)
        if (a.isAllDay && !b.isAllDay) return 1;
        if (!a.isAllDay && b.isAllDay) return -1;

        // For services with same all-day status, sort by duty type order
        final provider = Provider.of<ScheduleProvider>(context, listen: false);
        final activeConfig = provider.activeConfig;

        if (activeConfig == null) {
          // Fallback to alphabetical sorting if no config available
          final dutyTypeA = activeConfig?.dutyTypes[a.service];
          final dutyTypeB = activeConfig?.dutyTypes[b.service];

          final labelA = dutyTypeA?.label ?? a.service;
          final labelB = dutyTypeB?.label ?? b.service;

          return labelA.compareTo(labelB);
        }

        final orderA = activeConfig.dutyTypeOrder.indexOf(a.service);
        final orderB = activeConfig.dutyTypeOrder.indexOf(b.service);

        // If both services are in the order list, sort by their position
        if (orderA != -1 && orderB != -1) {
          return orderA.compareTo(orderB);
        }

        // If only one service is in the order list, prioritize it
        if (orderA != -1) return -1;
        if (orderB != -1) return 1;

        // If neither service is in the order list, sort alphabetically
        final dutyTypeA = activeConfig.dutyTypes[a.service];
        final dutyTypeB = activeConfig.dutyTypes[b.service];

        final labelA = dutyTypeA?.label ?? a.service;
        final labelB = dutyTypeB?.label ?? b.service;

        return labelA.compareTo(labelB);
      });
  }

  List<Schedule> _filterSchedules(List<Schedule> schedules) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final selectedDay = provider.selectedDay;
    final activeConfig = provider.activeConfig;

    if (selectedDay == null || activeConfig == null) {
      return [];
    }

    final filteredSchedules = schedules.where((schedule) {
      final isSameDay = schedule.date.year == selectedDay.year &&
          schedule.date.month == selectedDay.month &&
          schedule.date.day == selectedDay.day;
      final isActiveConfig = schedule.configName == activeConfig.meta.name;
      final isSelectedDutyGroup = widget.selectedDutyGroup == null ||
          schedule.dutyGroupName == widget.selectedDutyGroup;
      return isSameDay && isActiveConfig && isSelectedDutyGroup;
    }).toList();

    return filteredSchedules;
  }

  IconData _getDutyTypeIcon(String serviceId, ScheduleProvider provider) {
    final dutyType = provider.activeConfig?.dutyTypes[serviceId];

    // Use the icon from the duty type if available
    if (dutyType?.icon != null) {
      return IconMapper.getIcon(dutyType!.icon!, defaultIcon: Icons.schedule);
    }

    // Fallback to default schedule icon
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sortedSchedules = _getFilteredAndSortedSchedules();
    final provider = Provider.of<ScheduleProvider>(context);

    // Initialize current schedules if empty
    if (_currentSchedules.isEmpty && sortedSchedules.isNotEmpty) {
      _currentSchedules = List.from(sortedSchedules);
      _animationController.forward();
    }

    if (sortedSchedules.isEmpty) {
      return Center(
        child: Text(l10n.noServicesForDay),
      );
    }

    return Column(
      children: [
        // Filter status text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '${l10n.filteredBy}: ${widget.selectedDutyGroup ?? l10n.all}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Animated duty list
        Expanded(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    itemCount: sortedSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = sortedSchedules[index];
                      final dutyType =
                          provider.activeConfig?.dutyTypes[schedule.service];
                      final serviceName = dutyType?.label ?? schedule.service;

                      final isSelected =
                          widget.selectedDutyGroup == schedule.dutyGroupName;
                      final mainColor = Theme.of(context).colorScheme.primary;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (widget.onDutyGroupSelected != null) {
                                widget.onDutyGroupSelected!(
                                    isSelected ? null : schedule.dutyGroupName);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? mainColor.withAlpha(20)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? mainColor
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icon on the left
                                  Icon(
                                    _getDutyTypeIcon(
                                        schedule.service, provider),
                                    color: mainColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),

                                  // Service type text in the center
                                  Expanded(
                                    child: Text(
                                      serviceName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Duty group hint on the right
                                  Text(
                                    schedule.dutyGroupName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
