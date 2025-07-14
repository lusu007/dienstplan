import 'package:flutter/material.dart';

mixin DraggableSheetAnimationMixin<T extends StatefulWidget> on State<T> {
  bool _shouldAnimateScheduleList = false;

  bool get shouldAnimateScheduleList => _shouldAnimateScheduleList;

  void triggerAnimation() {
    // Set animation flag
    setState(() {
      _shouldAnimateScheduleList = true;
    });

    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _shouldAnimateScheduleList = false;
        });
      }
    });
  }

  void resetAnimation() {
    if (mounted) {
      setState(() {
        _shouldAnimateScheduleList = false;
      });
    }
  }
}
