import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view_controller.dart';
import 'package:table_calendar/table_calendar.dart';

/// Optimized draggable sheet with AutomaticKeepAliveClientMixin
class DraggableSheet extends ConsumerStatefulWidget {
  final CalendarViewController pageManager;
  final Key pageViewKey;
  final Function(int) onPageChanged;
  final Widget Function(DateTime) buildSheetContent;

  const DraggableSheet({
    super.key,
    required this.pageManager,
    required this.pageViewKey,
    required this.onPageChanged,
    required this.buildSheetContent,
  });

  @override
  ConsumerState<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends ConsumerState<DraggableSheet>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer(
      builder: (context, ref, child) {
        // Watch for calendar format changes
        final calendarState = ref.watch(calendarProvider);
        final currentFormat =
            calendarState.value?.calendarFormat ?? CalendarFormat.month;

        // Define static snap points for each calendar format
        final snapPoints = _getSnapPoints(currentFormat);
        final snapMinHeight = snapPoints.first;
        final initialHeight = snapPoints.first;
        final maxHeight = snapPoints.length > 1
            ? snapPoints[1]
            : snapPoints.first;

        return RepaintBoundary(
          child: CalendarViewUiBuilder.buildDraggableSheetContainer(
            context: context,
            initialHeight: initialHeight,
            minHeight: snapMinHeight,
            maxHeight: maxHeight,
            snapPoints: snapPoints,
            onHeightChanged: () {
              // Don't call setState here to avoid build error
              // The Consumer will automatically rebuild when needed
            },
            child: Column(
              children: [
                _ServicesSectionWrapper(pageManager: widget.pageManager),
                // Filter status text (always visible, never animated)
                CalendarViewUiBuilder.buildFilterStatusText(context: context),
                Expanded(
                  child: SizedBox(
                    height: 250.0, // Fixed height to prevent overflow
                    child: PageView.builder(
                      key: widget.pageViewKey,
                      controller: widget.pageManager.pageController,
                      onPageChanged: widget.onPageChanged,
                      itemCount: widget.pageManager.dayPages.length,
                      physics: const PageScrollPhysics(),
                      itemBuilder: (context, index) {
                        final day = widget.pageManager.dayPages[index];
                        return RepaintBoundary(
                          child: widget.buildSheetContent(day),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<double> _getSnapPoints(CalendarFormat format) {
    final double viewportHeight = MediaQuery.of(context).size.height;

    // Compute responsive snap points with safe clamping to the viewport.
    // This prevents the sheet from covering the calendar on smaller devices.
    final double minSnapMonth = math.min(240.0, viewportHeight * 0.28);
    final double maxSnapMonth = math.min(550.0, viewportHeight * 0.70);
    final double minSnapTwoWeeks = math.min(420.0, viewportHeight * 0.55);
    final double maxSnapTwoWeeks = math.min(550.0, viewportHeight * 0.78);
    final double minSnapWeek = math.min(480.0, viewportHeight * 0.65);
    final double maxSnapWeek = math.min(550.0, viewportHeight * 0.82);

    switch (format) {
      case CalendarFormat.month:
        return <double>[minSnapMonth, maxSnapMonth];
      case CalendarFormat.twoWeeks:
        return <double>[minSnapTwoWeeks, maxSnapTwoWeeks];
      case CalendarFormat.week:
        return <double>[minSnapWeek, maxSnapWeek];
    }
  }
}

/// Optimized services section wrapper with AutomaticKeepAliveClientMixin
class _ServicesSectionWrapper extends ConsumerStatefulWidget {
  final CalendarViewController pageManager;

  const _ServicesSectionWrapper({required this.pageManager});

  @override
  ConsumerState<_ServicesSectionWrapper> createState() =>
      _ServicesSectionWrapperState();
}

class _ServicesSectionWrapperState
    extends ConsumerState<_ServicesSectionWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.pageManager.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageManager.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: Consumer(
        builder: (context, ref, _) {
          final selectedDay = ref.watch(calendarProvider).value?.selectedDay;
          return CalendarViewUiBuilder.buildServicesSection(
            selectedDay: selectedDay,
          );
        },
      ),
    );
  }
}
