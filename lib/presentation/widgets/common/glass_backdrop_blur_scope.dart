import 'package:flutter/widgets.dart';

/// Controls whether nested glass controls should apply their own BackdropFilter.
///
/// Modal glass surfaces already blur the page behind them. Disabling descendant
/// blur keeps the same translucent tint/border styling while avoiding multiple
/// overlapping blur passes during sheet route animations and drag gestures.
class GlassBackdropBlurScope extends InheritedWidget {
  final bool enabled;

  const GlassBackdropBlurScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  static bool enabledOf(BuildContext context) {
    final GlassBackdropBlurScope? scope = context
        .dependOnInheritedWidgetOfExactType<GlassBackdropBlurScope>();
    return scope?.enabled ?? true;
  }

  @override
  bool updateShouldNotify(GlassBackdropBlurScope oldWidget) {
    return enabled != oldWidget.enabled;
  }
}
