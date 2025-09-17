import 'package:flutter/material.dart';

class SetupBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? mainColor;
  final double size;

  const SetupBackButton({
    super.key,
    this.onPressed,
    this.mainColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMainColor =
        mainColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveMainColor,
          side: BorderSide(color: effectiveMainColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Icon(Icons.arrow_back, size: 24, color: effectiveMainColor),
      ),
    );
  }
}
