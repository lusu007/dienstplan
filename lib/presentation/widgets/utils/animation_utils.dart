import 'package:flutter/material.dart';

class AnimationUtils {
  // Standard animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Standard animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;

  // Standard animation patterns
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.1, 0.0),
    Offset end = Offset.zero,
    Curve curve = easeOut,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 1.0,
    double end = 1.1,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static Animation<double> createRotationAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  // Staggered animations
  static List<Animation<double>> createStaggeredAnimations(
    AnimationController controller,
    int count, {
    Duration staggerDuration = const Duration(milliseconds: 100),
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeOut,
  }) {
    final animations = <Animation<double>>[];

    for (int i = 0; i < count; i++) {
      final startTime = (i * staggerDuration.inMilliseconds) /
          controller.duration!.inMilliseconds;
      final endTime = ((i + 1) * staggerDuration.inMilliseconds) /
          controller.duration!.inMilliseconds;

      animations.add(
        Tween<double>(
          begin: begin,
          end: end,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(startTime, endTime, curve: curve),
          ),
        ),
      );
    }

    return animations;
  }

  // Animation controllers with standard configurations
  static AnimationController createAnimationController(
    TickerProvider vsync, {
    Duration duration = normal,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  // Utility methods for common animations
  static void triggerBounceAnimation(AnimationController controller) {
    controller.forward().then((_) {
      controller.reverse();
    });
  }

  static void triggerPulseAnimation(AnimationController controller) {
    controller.forward().then((_) {
      controller.reverse();
    });
  }

  static void triggerShakeAnimation(AnimationController controller) {
    controller.forward().then((_) {
      controller.reverse();
    });
  }
}
