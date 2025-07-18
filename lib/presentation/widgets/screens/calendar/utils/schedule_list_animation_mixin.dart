import 'package:flutter/material.dart';

mixin ScheduleListAnimationMixin<T extends StatefulWidget> on State<T> {
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  bool hasAnimated = false;

  void initializeAnimations(TickerProvider vsync) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void disposeAnimations() {
    animationController.dispose();
  }

  void triggerAnimation() {
    if (!hasAnimated) {
      hasAnimated = true;
      animationController.reset();
      animationController.forward();

      // Reset the flag after animation completes
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            hasAnimated = false;
          });
        }
      });
    }
  }

  Widget buildAnimatedContent(Widget child) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
