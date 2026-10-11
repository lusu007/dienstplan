import 'package:flutter/material.dart';

/// Enter the foreground after the route has become opaque. This avoids
/// compositing the calendar behind the entrance while retaining native back
/// progress and cancellation for navigation within settings.
class SettingsPageTransition extends StatefulWidget {
  const SettingsPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  static Widget buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SettingsPageTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    child: child,
  );

  // Settings foregrounds animate on an opaque, stationary background. Keeping
  // covered pages alive but offstage avoids rendering their hidden glass filters.
  static Widget _coveredPage(Animation<double> secondary, Widget child) =>
      AnimatedBuilder(
        animation: secondary,
        child: child,
        builder: (_, child) => Visibility(
          visible:
              secondary.value == 0 &&
              secondary.status == AnimationStatus.dismissed,
          maintainState: true,
          maintainAnimation: false,
          child: child!,
        ),
      );

  @override
  State<SettingsPageTransition> createState() => _SettingsPageTransitionState();
}

class _SettingsPageTransitionState extends State<SettingsPageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 270),
  );
  late Animation<double> _progress = _SettingsProgress(
    widget.animation,
    _entrance,
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    widget.animation.addStatusListener(_routeStatusChanged);
    widget.secondaryAnimation.addListener(_covered);
  }

  void _covered() {
    if (widget.secondaryAnimation.value > 0 && _entrance.value != 1) {
      _entrance.value = 1;
    }
  }

  void _routeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      _entrance.stop();
    } else if (status == AnimationStatus.forward && _entrance.value < 1) {
      _entrance.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if ((MediaQuery.disableAnimationsOf(context) ||
            MediaQuery.accessibleNavigationOf(context)) &&
        _entrance.value != 1) {
      _entrance.value = 1;
    }
  }

  @override
  void didUpdateWidget(SettingsPageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.animation.removeStatusListener(_routeStatusChanged);
    oldWidget.secondaryAnimation.removeListener(_covered);
    widget.animation.addStatusListener(_routeStatusChanged);
    widget.secondaryAnimation.addListener(_covered);
    _progress = _SettingsProgress(widget.animation, _entrance);
    _covered();
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_routeStatusChanged);
    widget.secondaryAnimation.removeListener(_covered);
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageTransition._coveredPage(
      widget.secondaryAnimation,
      SettingsPageMotionScope(
        animation: _progress,
        secondaryAnimation: widget.secondaryAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Move the foreground while the opaque aurora background stays in place.
/// Moving both complete pages exposes the calendar's expensive glass layers.
class SettingsPageMotionScope extends InheritedWidget {
  const SettingsPageMotionScope({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required super.child,
  });
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;

  static Widget wrap(BuildContext context, Widget child) {
    final motion = context
        .dependOnInheritedWidgetOfExactType<SettingsPageMotionScope>();
    if (motion == null ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      return child;
    }
    return AnimatedBuilder(
      animation: Listenable.merge([
        motion.animation,
        motion.secondaryAnimation,
      ]),
      child: child,
      builder: (context, child) {
        final interactive =
            Navigator.maybeOf(context)?.userGestureInProgress ?? false;
        final forward = interactive
            ? motion.animation.value
            : Curves.easeOutCubic.transform(motion.animation.value);
        final backward = interactive
            ? motion.secondaryAnimation.value
            : Curves.easeOutCubic.transform(motion.secondaryAnimation.value);
        final direction = Directionality.of(context) == TextDirection.rtl
            ? -1.0
            : 1.0;
        return SlideTransition(
          position: AlwaysStoppedAnimation(
            Offset(direction * (.12 * (1 - forward) - .06 * backward), 0),
          ),
          child: child,
        );
      },
    );
  }

  static Widget fadeTitle(BuildContext context, Widget child) {
    final motion = context
        .dependOnInheritedWidgetOfExactType<SettingsPageMotionScope>();
    if (motion == null ||
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      return child;
    }
    return AnimatedBuilder(
      animation: motion.animation,
      child: child,
      builder: (context, child) => FadeTransition(
        opacity: AlwaysStoppedAnimation(
          Navigator.maybeOf(context)?.userGestureInProgress ?? false
              ? motion.animation.value
              : Curves.easeOutCubic.transform(motion.animation.value),
        ),
        child: child,
      ),
    );
  }

  @override
  bool updateShouldNotify(SettingsPageMotionScope oldWidget) =>
      animation != oldWidget.animation ||
      secondaryAnimation != oldWidget.secondaryAnimation;
}

class _SettingsProgress extends CompoundAnimation<double> {
  _SettingsProgress(Animation<double> route, Animation<double> entrance)
    : super(first: route, next: entrance);
  @override
  double get value => first.value * next.value;
}
