import 'package:flutter/material.dart';
import 'package:dienstplan/widgets/layout/section_header.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> cards;
  final EdgeInsets? padding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.cards,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        ...cards,
        if (padding != null) SizedBox(height: padding!.top),
      ],
    );
  }
}
