import 'package:flutter/material.dart';

class DraggableSheetContainer extends StatefulWidget {
  final Widget child;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final VoidCallback? onHeightChanged;
  final ValueChanged<double>? onHeightUpdate;
  final List<double>? snapPoints;

  const DraggableSheetContainer({
    super.key,
    required this.child,
    this.initialHeight = 300.0,
    this.minHeight = 150.0,
    this.maxHeight = 600.0,
    this.onHeightChanged,
    this.onHeightUpdate,
    this.snapPoints,
  });

  @override
  State<DraggableSheetContainer> createState() =>
      _DraggableSheetContainerState();
}

class _DraggableSheetContainerState extends State<DraggableSheetContainer>
    with TickerProviderStateMixin {
  late double _currentHeight;
  late double _effectiveMinHeight;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.initialHeight;
    _effectiveMinHeight = widget.minHeight;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: _currentHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(DraggableSheetContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if snap points changed (indicates calendar format change)
    if (oldWidget.snapPoints != null &&
        widget.snapPoints != null &&
        !_areSnapPointsEqual(oldWidget.snapPoints!, widget.snapPoints!)) {
      // Calendar format changed, adjust sheet height to new format
      _adjustHeightForNewFormat();
    }

    // Update effective min height if it changed
    if (oldWidget.minHeight != widget.minHeight) {
      final oldMinHeight = _effectiveMinHeight;
      _effectiveMinHeight = widget.minHeight;

      // If minHeight changed, always snap to the smallest snap point
      // This ensures consistent behavior across all calendar format changes
      if (widget.snapPoints != null && widget.snapPoints!.isNotEmpty) {
        final targetHeight = widget.snapPoints!.first;

        if (targetHeight != _currentHeight) {
          _currentHeight = targetHeight;
          _animateToHeight(targetHeight);

          // Notify about the height change
          widget.onHeightChanged?.call();
        }
      }
    }
  }

  bool _areSnapPointsEqual(List<double> points1, List<double> points2) {
    if (points1.length != points2.length) return false;
    for (int i = 0; i < points1.length; i++) {
      if (points1[i] != points2[i]) return false;
    }
    return true;
  }

  void _adjustHeightForNewFormat() {
    if (widget.snapPoints == null || widget.snapPoints!.isEmpty) return;

    // Always snap to the smallest snap point (0. index) when calendar format changes
    // This ensures consistent behavior and prevents the sheet from overlapping the calendar
    double targetHeight = widget.snapPoints!.first;

    // Ensure the target height is within bounds with safe clamping
    // Add safety checks to prevent invalid arguments
    final safeMinHeight =
        _effectiveMinHeight.isFinite ? _effectiveMinHeight : 0.0;
    final safeMaxHeight = widget.maxHeight.isFinite ? widget.maxHeight : 1000.0;

    if (targetHeight < safeMinHeight) {
      targetHeight = safeMinHeight;
    } else if (targetHeight > safeMaxHeight) {
      targetHeight = safeMaxHeight;
    }

    // Animate to the new height
    if (targetHeight != _currentHeight) {
      _currentHeight = targetHeight;
      _animateToHeight(targetHeight);

      // Notify about the height change
      widget.onHeightChanged?.call();
    }
  }

  void _animateToHeight(double targetHeight) {
    _heightAnimation = Tween<double>(
      begin: _heightAnimation.value,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final newHeight = (_currentHeight - details.delta.dy)
            .clamp(_effectiveMinHeight, widget.maxHeight);

        if ((newHeight - _currentHeight).abs() > 1.0) {
          _currentHeight = newHeight;

          // During dragging, update height immediately without animation
          // This makes the sheet "stick" to the finger
          _heightAnimation = Tween<double>(
            begin: _currentHeight,
            end: _currentHeight,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.linear,
          ));

          // Force immediate update
          _animationController.value = 1.0;

          // Only call onHeightChanged occasionally to reduce rebuilds
          if (_currentHeight % 10 < 5) {
            widget.onHeightChanged?.call();
          }

          // Always notify about height updates for real-time positioning
          widget.onHeightUpdate?.call(_currentHeight);
        }
      },
      onPanEnd: (details) {
        // If snap points are provided, snap to the nearest one
        double targetHeight = _currentHeight;
        if (widget.snapPoints != null && widget.snapPoints!.isNotEmpty) {
          // Find the nearest snap point
          double nearestSnapPoint = widget.snapPoints!.first;
          double minDistance = (_currentHeight - nearestSnapPoint).abs();

          for (final snapPoint in widget.snapPoints!) {
            final distance = (_currentHeight - snapPoint).abs();
            if (distance < minDistance) {
              minDistance = distance;
              nearestSnapPoint = snapPoint;
            }
          }

          // Snap to the nearest point - ensure it's exactly one of the defined snap points
          targetHeight = nearestSnapPoint;
          _currentHeight = targetHeight;
        }

        // Animate to final position smoothly
        _heightAnimation = Tween<double>(
          begin: _heightAnimation.value,
          end: targetHeight,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ));
        _animationController.forward(from: 0.0);

        // Final callback
        widget.onHeightChanged?.call();
      },
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return Container(
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
