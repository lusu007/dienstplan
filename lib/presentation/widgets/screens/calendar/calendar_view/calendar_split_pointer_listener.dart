import 'package:flutter/material.dart';

/// Detects a dominant vertical pan on the calendar. In full month mode, a
/// clear upward motion asks for [onSwipeUpInFull]. In split mode, a downward
/// motion asks for [onSwipeDownInSplit]. Coexists with the month
/// [PageView] as long as the gesture is mostly vertical.
class CalendarSplitPointerListener extends StatefulWidget {
  const CalendarSplitPointerListener({
    super.key,
    required this.isSplitLayout,
    this.onSwipeUpInFull,
    this.onSwipeDownInSplit,
    required this.child,
  });

  final bool isSplitLayout;
  final VoidCallback? onSwipeUpInFull;
  final VoidCallback? onSwipeDownInSplit;
  final Widget child;

  @override
  State<CalendarSplitPointerListener> createState() =>
      _CalendarSplitPointerListenerState();
}

class _CalendarSplitPointerListenerState
    extends State<CalendarSplitPointerListener> {
  static const double _distanceThreshold = 64.0;
  double _dx = 0;
  double _dy = 0;

  void _reset() {
    _dx = 0;
    _dy = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        _reset();
      },
      onPointerMove: (PointerMoveEvent e) {
        _dx += e.delta.dx;
        _dy += e.delta.dy;
      },
      onPointerUp: (_) {
        _onPointerEnd();
      },
      onPointerCancel: (_) {
        _onPointerEnd();
      },
      child: widget.child,
    );
  }

  void _onPointerEnd() {
    final bool verticalDominant = _dy.abs() >= _dx.abs() * 1.15;
    if (!verticalDominant) {
      _reset();
      return;
    }
    if (!widget.isSplitLayout) {
      if (_dy < -_distanceThreshold) {
        widget.onSwipeUpInFull?.call();
      }
    } else {
      if (_dy > _distanceThreshold) {
        widget.onSwipeDownInSplit?.call();
      }
    }
    _reset();
  }
}
