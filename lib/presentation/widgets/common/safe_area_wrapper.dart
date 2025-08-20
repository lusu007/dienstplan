import 'package:flutter/material.dart';

/// A wrapper widget that provides consistent safe area handling across the app.
/// This ensures that content doesn't hide behind system UI elements like the
/// status bar or navigation bar.
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool maintainBottomViewPadding;
  final EdgeInsets? minimum;

  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.maintainBottomViewPadding = true,
    this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: maintainBottomViewPadding,
      minimum: minimum ?? EdgeInsets.zero,
      child: child,
    );
  }
}

/// A wrapper widget that provides safe area handling with custom padding.
/// Useful for screens that need specific padding in addition to safe area.
class SafeAreaWithPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool maintainBottomViewPadding;

  const SafeAreaWithPadding({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maintainBottomViewPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
