import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [child, const SizedBox(height: 32)],
      ),
    );
  }
}
