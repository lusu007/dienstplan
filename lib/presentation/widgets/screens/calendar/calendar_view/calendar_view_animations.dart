import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/animation_constants.dart';

mixin CalendarViewAnimations<T extends StatefulWidget> on State<T> {
  bool _shouldAnimateScheduleList = false;

  bool get shouldAnimateScheduleList => _shouldAnimateScheduleList;

  void triggerAnimation() {
    // Set animation flag
    setState(() {
      _shouldAnimateScheduleList = true;
    });

    // Reset animation flag after animation completes
    Future.delayed(kAnimDefault, () {
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
