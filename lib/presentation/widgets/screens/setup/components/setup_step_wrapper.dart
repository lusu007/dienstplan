import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';

/// Scroll container for a single setup step with a soft top/bottom fade so
/// content dissolves into the setup header and the action buttons instead
/// of being cut off hard.
class SetupStepWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;

  const SetupStepWrapper({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollFadeMask(
      topFadeFraction: 0.04,
      bottomFadeFraction: 0.04,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [child, const SizedBox(height: 32)],
        ),
      ),
    );
  }
}
