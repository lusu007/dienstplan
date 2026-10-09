import 'package:flutter/material.dart';

/// Applies a vertical fade at the top and/or bottom edge of its child.
///
/// Used to softly fade scrollable content into the transparent headers of
/// the glass UI so items that scroll under the header dissolve instead of
/// being cut off at a hard edge.
///
/// [topFadeFraction] and [bottomFadeFraction] are expressed as fractions of
/// the child's rendered height (e.g. `0.05` means the first / last 5 percent
/// of the area fade to fully transparent). Set either to `0` to disable the
/// fade on that edge.
class ScrollFadeMask extends StatefulWidget {
  final Widget child;
  final double topFadeFraction;
  final double bottomFadeFraction;
  final bool enabled;
  final bool deferDuringSheetTransition;

  const ScrollFadeMask({
    super.key,
    required this.child,
    this.topFadeFraction = 0.05,
    this.bottomFadeFraction = 0.06,
    this.enabled = true,
    this.deferDuringSheetTransition = false,
  });

  @override
  State<ScrollFadeMask> createState() => _ScrollFadeMaskState();
}

class _ScrollFadeMaskState extends State<ScrollFadeMask> {
  Animation<double>? _animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    final animation = route is ModalBottomSheetRoute ? route.animation : null;
    if (_animation == animation) return;
    _animation?.removeStatusListener(_onStatus);
    _animation = animation;
    _animation?.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus _) {
    if (mounted && widget.deferDuringSheetTransition) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animation?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        (widget.deferDuringSheetTransition &&
            _animation != null &&
            _animation!.status != AnimationStatus.completed)) {
      return widget.child;
    }
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
            widget.topFadeFraction.clamp(0.0, 0.5),
            (1.0 - widget.bottomFadeFraction).clamp(0.5, 1.0),
            1.0,
          ],
        ).createShader(rect);
      },
      child: widget.child,
    );
  }
}
