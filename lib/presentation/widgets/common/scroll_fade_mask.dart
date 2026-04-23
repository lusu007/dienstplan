import 'package:flutter/material.dart';

/// Applies a vertical fade at the top and/or bottom edge of its child.
///
/// Used to softly fade scrollable content into the transparent headers of
/// the glass UI so items that scroll under the header dissolve instead of
/// being cut off at a hard edge.
///
/// [topFadeFraction] and [bottomFadeFraction] are expressed as fractions of
/// the child's rendered height (e.g. `0.04` means the first / last 4 percent
/// of the area fade to fully transparent). Set either to `0` to disable the
/// fade on that edge.
class ScrollFadeMask extends StatelessWidget {
  final Widget child;
  final double topFadeFraction;
  final double bottomFadeFraction;

  const ScrollFadeMask({
    super.key,
    required this.child,
    this.topFadeFraction = 0.04,
    this.bottomFadeFraction = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [
            0.0,
            topFadeFraction.clamp(0.0, 0.5),
            (1.0 - bottomFadeFraction).clamp(0.5, 1.0),
            1.0,
          ],
        ).createShader(rect);
      },
      child: child,
    );
  }
}
