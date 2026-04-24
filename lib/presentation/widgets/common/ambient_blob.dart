import 'package:flutter/material.dart';

/// Soft radial color blob used behind glass surfaces.
class AmbientBlob extends StatelessWidget {
  final Color color;
  final double diameter;

  const AmbientBlob({super.key, required this.color, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
