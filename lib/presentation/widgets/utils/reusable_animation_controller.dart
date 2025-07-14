import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/utils/animation_utils.dart';

class ReusableAnimationController {
  late final AnimationController controller;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<double> rotationAnimation;

  ReusableAnimationController({
    required TickerProvider vsync,
    Duration duration = AnimationUtils.normal,
  }) {
    controller =
        AnimationUtils.createAnimationController(vsync, duration: duration);

    fadeAnimation = AnimationUtils.createFadeAnimation(controller);
    slideAnimation = AnimationUtils.createSlideAnimation(controller);
    scaleAnimation = AnimationUtils.createScaleAnimation(controller);
    rotationAnimation = AnimationUtils.createRotationAnimation(controller);
  }

  void dispose() {
    controller.dispose();
  }

  // Standard animation triggers
  void fadeIn() {
    controller.forward();
  }

  void fadeOut() {
    controller.reverse();
  }

  void bounce() {
    AnimationUtils.triggerBounceAnimation(controller);
  }

  void pulse() {
    AnimationUtils.triggerPulseAnimation(controller);
  }

  void shake() {
    AnimationUtils.triggerShakeAnimation(controller);
  }

  // Custom animation triggers
  void animateTo(double value) {
    controller.animateTo(value);
  }

  void animateFrom(double value) {
    controller.value = value;
  }

  void repeat({bool reverse = false}) {
    controller.repeat(reverse: reverse);
  }

  void stop() {
    controller.stop();
  }

  void reset() {
    controller.reset();
  }

  // Status getters
  bool get isAnimating => controller.isAnimating;
  bool get isCompleted => controller.isCompleted;
  bool get isDismissed => controller.isDismissed;
  double get value => controller.value;
}

class StaggeredAnimationController {
  late final AnimationController controller;
  late final List<Animation<double>> staggeredAnimations;

  StaggeredAnimationController({
    required TickerProvider vsync,
    required int itemCount,
    Duration duration = AnimationUtils.slow,
    Duration staggerDuration = const Duration(milliseconds: 100),
  }) {
    controller =
        AnimationUtils.createAnimationController(vsync, duration: duration);
    staggeredAnimations = AnimationUtils.createStaggeredAnimations(
      controller,
      itemCount,
      staggerDuration: staggerDuration,
    );
  }

  void dispose() {
    controller.dispose();
  }

  void start() {
    controller.forward();
  }

  void reverse() {
    controller.reverse();
  }

  void reset() {
    controller.reset();
  }

  Animation<double> getAnimation(int index) {
    if (index >= 0 && index < staggeredAnimations.length) {
      return staggeredAnimations[index];
    }
    return const AlwaysStoppedAnimation(1.0);
  }
}
