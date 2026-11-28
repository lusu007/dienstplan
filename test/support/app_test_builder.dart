import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:flutter/widgets.dart';

/// Mirrors the production app's design scopes below MaterialApp's theme/labels.
TransitionBuilder appTestBuilder({TransitionBuilder? builder}) {
  return (context, child) => AppGlassTheme(
    child: Builder(
      builder: (context) =>
          builder?.call(context, child) ?? child ?? const SizedBox.shrink(),
    ),
  );
}
