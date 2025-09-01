import 'package:flutter/material.dart';

class DraggableSheetContainer extends StatefulWidget {
  final Widget child;
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final VoidCallback? onHeightChanged;
  final ValueChanged<double>? onHeightUpdate;

  const DraggableSheetContainer({
    super.key,
    required this.child,
    this.initialHeight = 300.0,
    this.minHeight = 150.0,
    this.maxHeight = 600.0,
    this.onHeightChanged,
    this.onHeightUpdate,
  });

  @override
  State<DraggableSheetContainer> createState() =>
      _DraggableSheetContainerState();
}

class _DraggableSheetContainerState extends State<DraggableSheetContainer>
    with TickerProviderStateMixin {
  late double _currentHeight;
  late double _effectiveMinHeight;
  bool _isDragging = false;
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
    // Update effective min height if it changed
    if (oldWidget.minHeight != widget.minHeight) {
      final oldMinHeight = _effectiveMinHeight;
      _effectiveMinHeight = widget.minHeight;

      // If minHeight increased, we need to adjust current height
      if (widget.minHeight > oldMinHeight) {
        // New minHeight is higher, adjust current height if needed
        if (_currentHeight < _effectiveMinHeight) {
          _currentHeight = _effectiveMinHeight;
          _animateToHeight(_currentHeight);
        }
      } else {
        // New minHeight is lower (calendar got bigger), reduce sheet height
        // Calculate a reasonable new height that's not too small
        final targetHeight = (_currentHeight + _effectiveMinHeight) / 2;
        final newHeight =
            targetHeight.clamp(_effectiveMinHeight, _currentHeight);

        if (newHeight != _currentHeight) {
          _currentHeight = newHeight;
          _animateToHeight(_currentHeight);
        }
      }

      // Always notify about height changes
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
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        print('DraggableSheet: Pan started at ${details.globalPosition}');
      },
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
        setState(() {
          _isDragging = false;
        });

        // Animate to final position smoothly
        _heightAnimation = Tween<double>(
          begin: _heightAnimation.value,
          end: _currentHeight,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ));
        _animationController.forward(from: 0.0);

        // Final callback
        widget.onHeightChanged?.call();

        print('DraggableSheet: Pan ended, final height: $_currentHeight');
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
