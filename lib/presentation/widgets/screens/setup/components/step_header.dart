import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final String title;
  final String description;

  const StepHeader({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(description, style: const TextStyle(fontSize: 18.0)),
      ],
    );
  }
}
